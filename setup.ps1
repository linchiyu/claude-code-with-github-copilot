# Claude Code with GitHub Copilot Integration
# Automated Setup Script for Windows PowerShell

# Colors for output
$ESC = [char]27
$RED = "$ESC[31m"
$GREEN = "$ESC[32m"
$YELLOW = "$ESC[33m"
$BLUE = "$ESC[34m"
$NC = "$ESC[0m"

function Print-Step {
    param($Step, $Message)
    Write-Host "${BLUE}[STEP $Step]${NC} $Message"
}

function Print-Success {
    param($Message)
    Write-Host "${GREEN}✓${NC} $Message"
}

function Print-Error {
    param($Message)
    Write-Host "${RED}✗${NC} $Message"
}

function Print-Warning {
    param($Message)
    Write-Host "${YELLOW}⚠${NC} $Message"
}

function Test-Command {
    param($Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function New-UUID {
    return "litellm-$([guid]::NewGuid().ToString())"
}

Write-Host "========================================="
Write-Host "Claude Code + GitHub Copilot Setup"
Write-Host "========================================="
Write-Host ""

# Step 1: Check prerequisites
Print-Step "1/9" "Checking prerequisites..."

if (-not (Test-Command python) -and -not (Test-Command python3)) {
    Print-Error "Python is not installed. Please install Python 3.8+ first."
    Write-Host "Install from: https://www.python.org/downloads/"
    exit 1
}
Print-Success "Python found"

if (-not (Test-Command pip) -and -not (Test-Command pip3)) {
    Print-Error "pip is not installed. Please install pip first."
    exit 1
}
Print-Success "pip found"

if (-not (Test-Command gh)) {
    Print-Error "GitHub CLI (gh) is not installed."
    Write-Host "Install with: winget install --id GitHub.cli"
    Write-Host "Or from: https://cli.github.com/"
    exit 1
}
Print-Success "GitHub CLI found"

# Step 2: Install LiteLLM
Print-Step "2/9" "Installing LiteLLM..."
try {
    if (Test-Command pip3) {
        pip3 install 'litellm[proxy]' --quiet 2>&1 | Out-Null
    } else {
        pip install 'litellm[proxy]' --quiet 2>&1 | Out-Null
    }
    Print-Success "LiteLLM installed"
}
catch {
    Print-Error "Failed to install LiteLLM: $_"
    exit 1
}

# Step 3: Generate UUID
Print-Step "3/9" "Generating secure UUIDs..."
$UUID = New-UUID
Print-Success "UUID generated: $UUID"

# Step 4: Update litellm-keys.env
Print-Step "4/9" "Configuring environment variables..."
$envContent = @"
LITELLM_MASTER_KEY="$UUID"
LITELLM_SALT_KEY="$UUID"
"@
Set-Content -Path "litellm-keys.env" -Value $envContent
Print-Success "Created litellm-keys.env"

# Step 5: Update settings.json
Print-Step "5/9" "Configuring Claude Code settings..."
$settingsContent = @"
{
  "autoUpdatesChannel": "latest",
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "$UUID",
    "ANTHROPIC_BASE_URL": "http://localhost:4000",
    "ANTHROPIC_MODEL": "claude-sonnet-4-5",
    "ANTHROPIC_SMALL_FAST_MODEL": "gpt-5.4"
  }
}
"@
Set-Content -Path "settings.json" -Value $settingsContent
Print-Success "Created settings.json"

# Step 6: Load environment variables
Print-Step "6/9" "Loading environment variables..."
$env:LITELLM_MASTER_KEY = $UUID
$env:LITELLM_SALT_KEY = $UUID
Print-Success "Environment variables loaded"

# Step 7: Authenticate GitHub
Print-Step "7/9" "Checking GitHub authentication..."
try {
    gh auth status 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Print-Success "Already authenticated with GitHub"
    } else {
        throw "Not authenticated"
    }
}
catch {
    Print-Warning "Not authenticated. Starting GitHub authentication..."
    gh auth login
    if ($LASTEXITCODE -eq 0) {
        Print-Success "GitHub authentication complete"
    } else {
        Print-Error "GitHub authentication failed"
        exit 1
    }
}

# Step 8: Test GitHub Copilot access
Print-Step "8/9" "Verifying GitHub Copilot access..."
try {
    gh copilot explain "hello world" 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Print-Success "GitHub Copilot access verified"
    } else {
        throw "Cannot access Copilot"
    }
}
catch {
    Print-Error "Cannot access GitHub Copilot. Please check your subscription."
    exit 1
}

# Step 9: Install settings to Claude Code
Print-Step "9/9" "Installing settings to Claude Code..."
Write-Host ""
Write-Host "Where would you like to install the settings?"
Write-Host "1) Project-level (.claude\settings.json) - Only this project"
Write-Host "2) User-level (~\.claude\settings.json) - All projects"
Write-Host "3) Both"
Write-Host "4) Skip (I'll do it manually)"
$choice = Read-Host "Enter choice [1-4]"

switch ($choice) {
    "1" {
        New-Item -ItemType Directory -Force -Path ".claude" | Out-Null
        Copy-Item "settings.json" ".claude\settings.json"
        Print-Success "Settings installed to .claude\settings.json"
    }
    "2" {
        New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude" | Out-Null
        Copy-Item "settings.json" "$env:USERPROFILE\.claude\settings.json"
        Print-Success "Settings installed to ~\.claude\settings.json"
    }
    "3" {
        New-Item -ItemType Directory -Force -Path ".claude" | Out-Null
        Copy-Item "settings.json" ".claude\settings.json"
        New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude" | Out-Null
        Copy-Item "settings.json" "$env:USERPROFILE\.claude\settings.json"
        Print-Success "Settings installed to both locations"
    }
    "4" {
        Print-Warning "Skipped settings installation"
    }
    default {
        Print-Error "Invalid choice. Please run setup again."
        exit 1
    }
}

Write-Host ""
Write-Host "========================================="
Write-Host "${GREEN}Setup Complete!${NC}"
Write-Host "========================================="
Write-Host ""
Write-Host "Next steps:"
Write-Host ""
Write-Host "1. Start LiteLLM proxy in a new PowerShell window:"
Write-Host "   ${BLUE}# Load environment variables${NC}"
Write-Host "   ${BLUE}Get-Content litellm-keys.env | ForEach-Object {${NC}"
Write-Host "   ${BLUE}  if (\`$_ -match '^([^=]+)=(.+)\$') {${NC}"
Write-Host "   ${BLUE}    \`$env:LITELLM_MASTER_KEY = \`$matches[2].Trim('\"')${NC}"
Write-Host "   ${BLUE}    \`$env:LITELLM_SALT_KEY = \`$matches[2].Trim('\"')${NC}"
Write-Host "   ${BLUE}  }${NC}"
Write-Host "   ${BLUE}}${NC}"
Write-Host ""
Write-Host "   ${BLUE}# Start LiteLLM${NC}"
Write-Host "   ${BLUE}litellm --config copilot-config.yaml${NC}"
Write-Host ""
Write-Host "2. Test the proxy (in another PowerShell window):"
Write-Host "   ${BLUE}curl http://localhost:4000/health${NC}"
Write-Host ""
Write-Host "3. Launch Claude Code and start coding!"
Write-Host ""
Write-Host "Your UUID for reference: $UUID"
Write-Host ""
Write-Host "Need help? Check docs\TROUBLESHOOTING.md"
Write-Host ""

# Create a helper script to start LiteLLM
$startScriptContent = @"
# Load environment variables
Get-Content litellm-keys.env | ForEach-Object {
  if (\`$_ -match '^([^=]+)=(.+)\$') {
    \`$name = \`$matches[1]
    \`$value = \`$matches[2].Trim('"')
    Set-Item -Path "env:\`$name" -Value \`$value
  }
}

# Start LiteLLM
Write-Host "Starting LiteLLM proxy..."
litellm --config copilot-config.yaml
"@
Set-Content -Path "start-litellm.ps1" -Value $startScriptContent
Print-Success "Created start-litellm.ps1 helper script"

Write-Host ""
Write-Host "Quick start: Run ${BLUE}.\start-litellm.ps1${NC} to start the proxy"
Write-Host ""
