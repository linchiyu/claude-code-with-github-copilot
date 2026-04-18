#!/bin/bash

# Helper script to start LiteLLM proxy
# This script loads environment variables and starts LiteLLM

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Starting LiteLLM Proxy...${NC}"
echo ""

# Check if litellm-keys.env exists
if [ ! -f "litellm-keys.env" ]; then
    echo -e "${RED}Error: litellm-keys.env not found!${NC}"
    echo "Please run ./setup.sh first or create litellm-keys.env manually."
    exit 1
fi

# Check if copilot-config.yaml exists
if [ ! -f "copilot-config.yaml" ]; then
    echo -e "${RED}Error: copilot-config.yaml not found!${NC}"
    exit 1
fi

# Load environment variables
echo -e "${BLUE}Loading environment variables...${NC}"
source litellm-keys.env

# Verify variables are set
if [ -z "$LITELLM_MASTER_KEY" ] || [ -z "$LITELLM_SALT_KEY" ]; then
    echo -e "${RED}Error: Environment variables not loaded!${NC}"
    echo "Please check litellm-keys.env file."
    exit 1
fi

echo -e "${GREEN}✓ Environment variables loaded${NC}"
echo ""

# Check if litellm is installed
if ! command -v litellm &> /dev/null; then
    echo -e "${RED}Error: LiteLLM is not installed!${NC}"
    echo "Install with: pip install 'litellm[proxy]'"
    exit 1
fi

echo -e "${GREEN}✓ LiteLLM found${NC}"
echo ""

# Check GitHub authentication
echo -e "${BLUE}Checking GitHub authentication...${NC}"
if ! gh auth status &> /dev/null; then
    echo -e "${RED}Warning: Not authenticated with GitHub!${NC}"
    echo "Run: gh auth login"
    echo ""
fi

# Start LiteLLM
echo -e "${BLUE}Starting LiteLLM proxy on http://localhost:4000${NC}"
echo -e "${BLUE}Press Ctrl+C to stop${NC}"
echo ""
echo "==============================================="
echo ""

litellm --config copilot-config.yaml
