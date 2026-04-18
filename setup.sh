#!/bin/bash

# Claude Code with GitHub Copilot - Automated Setup Script
# This script automates the entire setup process

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
    echo -e "${BLUE}[STEP $1]${NC} $2"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Generate UUID
generate_uuid() {
    if command_exists uuidgen; then
        echo "litellm-$(uuidgen | tr '[:upper:]' '[:lower:]')"
    elif command_exists python3; then
        python3 -c "import uuid; print('litellm-' + str(uuid.uuid4()))"
    elif command_exists python; then
        python -c "import uuid; print('litellm-' + str(uuid.uuid4()))"
    else
        print_error "Cannot generate UUID. Please install uuidgen or Python."
        exit 1
    fi
}

echo "=================================="
echo "Claude Code + GitHub Copilot Setup"
echo "=================================="
echo ""

# Step 1: Check prerequisites
print_step "1/9" "Checking prerequisites..."

if ! command_exists python3 && ! command_exists python; then
    print_error "Python is not installed. Please install Python 3.8+ first."
    exit 1
fi
print_success "Python found"

if ! command_exists pip3 && ! command_exists pip; then
    print_error "pip is not installed. Please install pip first."
    exit 1
fi
print_success "pip found"

if ! command_exists gh; then
    print_error "GitHub CLI (gh) is not installed."
    echo "Install from: https://cli.github.com/"
    exit 1
fi
print_success "GitHub CLI found"

# Step 2: Install LiteLLM
print_step "2/9" "Installing LiteLLM..."
if command_exists pip3; then
    pip3 install 'litellm[proxy]' --quiet
else
    pip install 'litellm[proxy]' --quiet
fi
print_success "LiteLLM installed"

# Step 3: Generate UUIDs
print_step "3/9" "Generating secure UUIDs..."
UUID=$(generate_uuid)
print_success "UUID generated: $UUID"

# Step 4: Update litellm-keys.env
print_step "4/9" "Configuring environment variables..."
cat > litellm-keys.env <<EOF
LITELLM_MASTER_KEY="$UUID"
LITELLM_SALT_KEY="$UUID"
EOF
print_success "Created litellm-keys.env"

# Step 5: Update settings.json
print_step "5/9" "Configuring Claude Code settings..."
cat > settings.json <<EOF
{
  "autoUpdatesChannel": "latest",
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "$UUID",
    "ANTHROPIC_BASE_URL": "http://localhost:4000",
    "ANTHROPIC_MODEL": "claude-sonnet-4-5",
    "ANTHROPIC_SMALL_FAST_MODEL": "gpt-5.4"
  }
}
EOF
print_success "Created settings.json"

# Step 6: Load environment variables
print_step "6/9" "Loading environment variables..."
export LITELLM_MASTER_KEY="$UUID"
export LITELLM_SALT_KEY="$UUID"
print_success "Environment variables loaded"

# Step 7: Authenticate GitHub
print_step "7/9" "Checking GitHub authentication..."
if gh auth status &> /dev/null; then
    print_success "Already authenticated with GitHub"
else
    print_warning "Not authenticated. Starting GitHub authentication..."
    gh auth login
    print_success "GitHub authentication complete"
fi

# Step 8: Test GitHub Copilot access
print_step "8/9" "Verifying GitHub Copilot access..."
if gh copilot explain "hello world" &> /dev/null; then
    print_success "GitHub Copilot access verified"
else
    print_error "Cannot access GitHub Copilot. Please check your subscription."
    exit 1
fi

# Step 9: Install settings to Claude Code
print_step "9/9" "Installing settings to Claude Code..."
echo ""
echo "Where would you like to install the settings?"
echo "1) Project-level (.claude/settings.json) - Only this project"
echo "2) User-level (~/.claude/settings.json) - All projects"
echo "3) Both"
echo "4) Skip (I'll do it manually)"
read -p "Enter choice [1-4]: " choice

case $choice in
    1)
        mkdir -p .claude
        cp settings.json .claude/settings.json
        print_success "Settings installed to .claude/settings.json"
        ;;
    2)
        mkdir -p ~/.claude
        cp settings.json ~/.claude/settings.json
        print_success "Settings installed to ~/.claude/settings.json"
        ;;
    3)
        mkdir -p .claude
        cp settings.json .claude/settings.json
        mkdir -p ~/.claude
        cp settings.json ~/.claude/settings.json
        print_success "Settings installed to both locations"
        ;;
    4)
        print_warning "Skipped settings installation"
        ;;
    *)
        print_error "Invalid choice. Please run setup again."
        exit 1
        ;;
esac

echo ""
echo "=================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "=================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Start LiteLLM proxy in a new terminal:"
echo -e "   ${BLUE}source litellm-keys.env${NC}"
echo -e "   ${BLUE}litellm --config copilot-config.yaml${NC}"
echo ""
echo "2. Test the proxy (in another terminal):"
echo -e "   ${BLUE}curl http://localhost:4000/health${NC}"
echo ""
echo "3. Launch Claude Code and start coding!"
echo ""
echo "Your UUID for reference: $UUID"
echo ""
echo "Need help? Check docs/TROUBLESHOOTING.md"
echo ""
