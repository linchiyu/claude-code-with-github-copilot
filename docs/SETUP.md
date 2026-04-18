# Detailed Setup Guide

This guide provides step-by-step instructions for setting up Claude Code with GitHub Copilot integration.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation Methods](#installation-methods)
3. [Configuration Details](#configuration-details)
4. [Verification](#verification)
5. [Platform-Specific Instructions](#platform-specific-instructions)

## Prerequisites

### Required Software

#### 1. Python 3.8+

**Check if installed:**
```bash
python3 --version
# or
python --version
```

**Installation:**
- **Mac:** `brew install python3`
- **Linux:** `sudo apt install python3 python3-pip` (Ubuntu/Debian)
- **Windows:** Download from [python.org](https://www.python.org/downloads/)

#### 2. GitHub CLI

**Check if installed:**
```bash
gh --version
```

**Installation:**
- **Mac:** `brew install gh`
- **Linux:** Follow [official guide](https://github.com/cli/cli/blob/trunk/docs/install_linux.md)
- **Windows:** `winget install --id GitHub.cli`

#### 3. GitHub Copilot Subscription

Verify you have an active subscription:
```bash
gh copilot explain "hello world"
```

If this fails, you need to:
1. Subscribe at [github.com/features/copilot](https://github.com/features/copilot)
2. Wait a few minutes for activation
3. Re-authenticate: `gh auth logout && gh auth login`

#### 4. Claude Code

Download from [claude.com/claude-code](https://claude.com/claude-code)

---

## Installation Methods

### Option 1: Automated Setup (Recommended)

```bash
git clone <your-repo-url>
cd claude-code-with-github-copilot
./setup.sh
```

The script will:
- ✅ Check all prerequisites
- ✅ Install LiteLLM
- ✅ Generate secure UUIDs
- ✅ Configure all files
- ✅ Authenticate GitHub
- ✅ Install settings to Claude Code

**Then start the proxy:**
```bash
source litellm-keys.env
litellm --config copilot-config.yaml
```

### Option 2: Manual Setup

Follow these steps if the automated script doesn't work on your system.

#### Step 1: Install LiteLLM

```bash
pip install 'litellm[proxy]'

# Verify installation
litellm --version
```

#### Step 2: Generate UUIDs

You need two identical UUIDs (one for master key, one for auth token).

**Mac/Linux:**
```bash
uuidgen | tr '[:upper:]' '[:lower:]'
```

**Python (Cross-platform):**
```bash
python3 -c "import uuid; print(str(uuid.uuid4()))"
```

**Online Generator:**
Visit [uuidgenerator.net](https://www.uuidgenerator.net/)

**Example UUID:** `550e8400-e29b-41d4-a716-446655440000`

#### Step 3: Configure Environment File

Edit `litellm-keys.env`:
```bash
LITELLM_MASTER_KEY="litellm-550e8400-e29b-41d4-a716-446655440000"
LITELLM_SALT_KEY="litellm-550e8400-e29b-41d4-a716-446655440000"
```

**Important:** Prefix with `litellm-`

#### Step 4: Configure Claude Settings

Edit `settings.json` with the **same UUID**:
```json
{
  "autoUpdatesChannel": "latest",
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "litellm-550e8400-e29b-41d4-a716-446655440000",
    "ANTHROPIC_BASE_URL": "http://localhost:4000",
    "ANTHROPIC_MODEL": "claude-sonnet-4-5",
    "ANTHROPIC_SMALL_FAST_MODEL": "gpt-5.4"
  }
}
```

#### Step 5: Load Environment Variables

**Mac/Linux:**
```bash
source litellm-keys.env

# Verify
echo $LITELLM_MASTER_KEY
```

**Windows PowerShell:**
```powershell
Get-Content litellm-keys.env | ForEach-Object {
  if ($_ -match '^([^=]+)=(.+)$') {
    $name = $matches[1]
    $value = $matches[2].Trim('"')
    [Environment]::SetEnvironmentVariable($name, $value, "Process")
  }
}

# Verify
$env:LITELLM_MASTER_KEY
```

**Windows CMD:**
```cmd
for /f "tokens=1,2 delims==" %a in (litellm-keys.env) do set %a=%b
```

#### Step 6: Authenticate GitHub CLI

```bash
gh auth login
```

Choose:
1. **GitHub.com**
2. **HTTPS**
3. **Login with a web browser** (recommended)
4. Copy the one-time code
5. Press Enter and authenticate in browser

Verify:
```bash
gh auth status
```

#### Step 7: Start LiteLLM Proxy

```bash
litellm --config copilot-config.yaml
```

**Expected output:**
```
LiteLLM: Proxy running on http://0.0.0.0:4000
```

**Keep this terminal running!**

#### Step 8: Test the Proxy

Open a **new terminal** and run:

```bash
curl --location 'http://0.0.0.0:4000/chat/completions' \
  --header 'Content-Type: application/json' \
  --header 'Editor-Version: CommandLine/1.0' \
  --data '{
    "model": "gpt-5.4",
    "messages": [
      {
        "role": "user",
        "content": "Hello, what model are you?"
      }
    ]
  }'
```

**Expected response:**
```json
{
  "id": "chatcmpl-...",
  "object": "chat.completion",
  "created": 1234567890,
  "model": "gpt-5.4",
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "I'm GPT-5.4..."
      }
    }
  ]
}
```

#### Step 9: Install Settings to Claude Code

**Project-level (recommended for testing):**
```bash
mkdir -p .claude
cp settings.json .claude/settings.json
```

**User-level (applies to all projects):**

Mac/Linux:
```bash
mkdir -p ~/.claude
cp settings.json ~/.claude/settings.json
```

Windows PowerShell:
```powershell
New-Item -ItemType Directory -Force -Path $env:USERPROFILE\.claude
Copy-Item settings.json $env:USERPROFILE\.claude\settings.json
```

Windows CMD:
```cmd
mkdir %USERPROFILE%\.claude
copy settings.json %USERPROFILE%\.claude\settings.json
```

#### Step 10: Launch Claude Code

1. Start Claude Code
2. Open any project
3. Try a command like "Hello, what model are you using?"
4. Check LiteLLM terminal for request logs

---

## Configuration Details

### copilot-config.yaml

This file configures available models:

```yaml
model_list:
  - model_name: gpt-5.4               # Fastest, great for quick tasks
    litellm_params:
      model: github_copilot/gpt-5.4
      drop_params: true
      extra_headers: 
        Editor-Version: "vscode/1.85.1"
        Copilot-Integration-Id: "vscode-chat"
        
  - model_name: claude-opus-4-5       # Most capable
    litellm_params:
      model: github_copilot/claude-opus-4.5
      drop_params: true
      extra_headers:
        Editor-Version: "vscode/1.85.1"
        Copilot-Integration-Id: "vscode-chat"
        
  - model_name: claude-sonnet-4-5     # Best balance
    litellm_params:
      model: github_copilot/claude-sonnet-4.5
      drop_params: true
      extra_headers:
        Editor-Version: "vscode/1.85.1"
        Copilot-Integration-Id: "vscode-chat"
```

### settings.json Explained

```json
{
  "autoUpdatesChannel": "latest",     // Keep Claude Code updated
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "...",    // Must match LITELLM_MASTER_KEY
    "ANTHROPIC_BASE_URL": "...",      // LiteLLM proxy URL
    "ANTHROPIC_MODEL": "...",         // Default model for main tasks
    "ANTHROPIC_SMALL_FAST_MODEL": "..." // Model for quick operations
  }
}
```

---

## Verification

### Health Check

```bash
curl http://localhost:4000/health
```

Expected: `{"status": "healthy"}`

### Model List

```bash
curl http://localhost:4000/models
```

Should show: `gpt-5.4`, `claude-opus-4-5`, `claude-sonnet-4-5`

### Test Each Model

**GPT-5.4:**
```bash
curl -X POST http://localhost:4000/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "gpt-5.4", "messages": [{"role": "user", "content": "Hi"}]}'
```

**Claude Sonnet:**
```bash
curl -X POST http://localhost:4000/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "claude-sonnet-4-5", "messages": [{"role": "user", "content": "Hi"}]}'
```

---

## Platform-Specific Instructions

### macOS

**Using Homebrew (recommended):**
```bash
# Install all prerequisites
brew install python3 gh

# Install LiteLLM
pip3 install 'litellm[proxy]'

# Run setup
./setup.sh
```

**Auto-start LiteLLM on login:**
```bash
# Create launch agent
cat > ~/Library/LaunchAgents/com.litellm.proxy.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.litellm.proxy</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/local/bin/litellm</string>
    <string>--config</string>
    <string>$PWD/copilot-config.yaml</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>LITELLM_MASTER_KEY</key>
    <string>YOUR_UUID_HERE</string>
    <key>LITELLM_SALT_KEY</key>
    <string>YOUR_UUID_HERE</string>
  </dict>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
</dict>
</plist>
EOF

# Load agent
launchctl load ~/Library/LaunchAgents/com.litellm.proxy.plist
```

### Linux

**Ubuntu/Debian:**
```bash
# Install prerequisites
sudo apt update
sudo apt install python3 python3-pip

# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Install LiteLLM
pip3 install 'litellm[proxy]'

# Run setup
./setup.sh
```

**Run as systemd service:**
```bash
# Create service file
sudo cat > /etc/systemd/system/litellm.service <<EOF
[Unit]
Description=LiteLLM Proxy
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$PWD
Environment="LITELLM_MASTER_KEY=YOUR_UUID_HERE"
Environment="LITELLM_SALT_KEY=YOUR_UUID_HERE"
ExecStart=/usr/local/bin/litellm --config $PWD/copilot-config.yaml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
sudo systemctl enable litellm
sudo systemctl start litellm

# Check status
sudo systemctl status litellm
```

### Windows

**Using PowerShell as Administrator:**
```powershell
# Install Python
winget install Python.Python.3.12

# Install GitHub CLI
winget install --id GitHub.cli

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install LiteLLM
pip install 'litellm[proxy]'

# Run setup (use Git Bash or WSL)
# Or follow manual steps above
```

**Run as Windows Service:**
Use [NSSM](https://nssm.cc/) (Non-Sucking Service Manager):
```powershell
# Download NSSM
winget install NSSM.NSSM

# Install service
nssm install LiteLLM "C:\Python312\Scripts\litellm.exe"
nssm set LiteLLM AppDirectory "C:\path\to\claude-code-with-github-copilot"
nssm set LiteLLM AppParameters "--config copilot-config.yaml"
nssm set LiteLLM AppEnvironmentExtra "LITELLM_MASTER_KEY=YOUR_UUID" "LITELLM_SALT_KEY=YOUR_UUID"

# Start service
nssm start LiteLLM
```

---

## Next Steps

After successful setup:

1. Read [Configuration Options](CONFIGURATION.md) to customize
2. Check [Troubleshooting](TROUBLESHOOTING.md) if issues arise
3. Learn about the [Architecture](ARCHITECTURE.md)
4. Start using Claude Code with GitHub Copilot models!

---

**Need help?** Open an issue on GitHub or check the troubleshooting guide.
