# Quick Start Guide

Get up and running with Claude Code + GitHub Copilot in 5 minutes.

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] **Python 3.8+** installed
- [ ] **pip** package manager
- [ ] **GitHub CLI** (`gh`) installed
- [ ] **Active GitHub Copilot subscription**
- [ ] **Claude Code** installed

Not sure? Run these checks:
```bash
python3 --version   # Should show 3.8 or higher
pip3 --version      # Should show any version
gh --version        # Should show GitHub CLI version
gh auth status      # Should show you're logged in
```

---

## Installation (Choose Your Method)

### 🚀 Method 1: Automated Setup (Recommended)

**Mac/Linux:**
```bash
git clone <your-repo-url>
cd claude-code-with-github-copilot
chmod +x setup.sh
./setup.sh
```

**Windows:**
```powershell
git clone <your-repo-url>
cd claude-code-with-github-copilot
.\setup.ps1
```

The script will:
1. ✅ Install LiteLLM
2. ✅ Generate UUIDs
3. ✅ Configure files
4. ✅ Authenticate GitHub
5. ✅ Install settings

Then skip to [Start LiteLLM](#start-litellm).

---

### 📝 Method 2: Manual Setup (5 Steps)

#### Step 1: Install LiteLLM
```bash
pip install 'litellm[proxy]'
```

#### Step 2: Generate UUID
```bash
# Mac/Linux
uuidgen

# Windows PowerShell
[guid]::NewGuid()

# Python (any OS)
python3 -c "import uuid; print('litellm-' + str(uuid.uuid4()))"
```

Copy the UUID (add `litellm-` prefix if not using Python command).

#### Step 3: Edit `litellm-keys.env`
```bash
LITELLM_MASTER_KEY="litellm-YOUR-UUID-HERE"
LITELLM_SALT_KEY="litellm-YOUR-UUID-HERE"
```

#### Step 4: Edit `settings.json`
Use the **same UUID**:
```json
{
  "autoUpdatesChannel": "latest",
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "litellm-YOUR-UUID-HERE",
    "ANTHROPIC_BASE_URL": "http://localhost:4000",
    "ANTHROPIC_MODEL": "claude-sonnet-4-5",
    "ANTHROPIC_SMALL_FAST_MODEL": "gpt-5.4"
  }
}
```

#### Step 5: Authenticate GitHub
```bash
gh auth login
```
Follow the prompts and authenticate via browser.

---

## Start LiteLLM

### Terminal 1: Load Environment & Start Proxy

**Mac/Linux:**
```bash
source litellm-keys.env
litellm --config copilot-config.yaml
```

**Windows PowerShell:**
```powershell
# Load environment
Get-Content litellm-keys.env | ForEach-Object {
  if ($_ -match '^([^=]+)=(.+)$') {
    $name = $matches[1]
    $value = $matches[2].Trim('"')
    Set-Item -Path "env:$name" -Value $value
  }
}

# Start LiteLLM
litellm --config copilot-config.yaml
```

**Windows (using helper script):**
```powershell
.\start-litellm.ps1
```

**Expected output:**
```
LiteLLM: Proxy running on http://0.0.0.0:4000
```

**Keep this terminal open!**

---

## Test the Setup

### Terminal 2: Test Proxy

**Test health endpoint:**
```bash
curl http://localhost:4000/health
```
Expected: `{"status": "healthy"}`

**Test model call:**
```bash
curl -X POST http://localhost:4000/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR-UUID-HERE" \
  -d '{
    "model": "gpt-5.4",
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 50
  }'
```

Should return a JSON response with model output.

---

## Configure Claude Code

### Option 1: Project-Level (Recommended for Testing)

```bash
# Mac/Linux
mkdir -p .claude
cp settings.json .claude/settings.json

# Windows PowerShell
New-Item -ItemType Directory -Force -Path .claude
Copy-Item settings.json .claude\settings.json
```

### Option 2: User-Level (All Projects)

```bash
# Mac/Linux
mkdir -p ~/.claude
cp settings.json ~/.claude/settings.json

# Windows PowerShell
New-Item -ItemType Directory -Force -Path $env:USERPROFILE\.claude
Copy-Item settings.json $env:USERPROFILE\.claude\settings.json
```

---

## Launch Claude Code

1. **Start Claude Code** (make sure LiteLLM is running!)
2. **Open any project** or create a new file
3. **Type a message:** "Hello, what model are you using?"
4. **Check Terminal 1** to see request logs in LiteLLM

You should see:
- Claude Code responds to your message
- LiteLLM logs show the request being processed
- Success! 🎉

---

## Troubleshooting

### ❌ "Connection refused"
**Problem:** LiteLLM isn't running
**Solution:** 
```bash
source litellm-keys.env  # Mac/Linux
litellm --config copilot-config.yaml
```

### ❌ "401 Unauthorized"
**Problem:** UUID mismatch
**Solution:** Verify UUIDs match in both files:
```bash
cat litellm-keys.env
cat settings.json
```

### ❌ "Model not found"
**Problem:** Model name doesn't match config
**Solution:** Check `copilot-config.yaml` for available models:
- `gpt-5.4`
- `claude-opus-4-5`
- `claude-sonnet-4-5`

### ❌ "Cannot access Copilot"
**Problem:** No active Copilot subscription
**Solution:**
1. Subscribe at [github.com/features/copilot](https://github.com/features/copilot)
2. Wait 5-10 minutes for activation
3. Re-authenticate: `gh auth logout && gh auth login`

### More Issues?
See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for detailed solutions.

---

## Next Steps

### 📚 Learn More
- **[Configuration Guide](docs/CONFIGURATION.md)** - Customize models and settings
- **[Architecture](docs/ARCHITECTURE.md)** - Understand how it works
- **[Full Setup Guide](docs/SETUP.md)** - Detailed instructions

### 🔧 Customize Your Setup

**Use different default model:**
```json
{
  "env": {
    "ANTHROPIC_MODEL": "gpt-5.4"  // Faster
    // or
    "ANTHROPIC_MODEL": "claude-opus-4-5"  // More powerful
  }
}
```

**Change port:**
Edit `copilot-config.yaml`:
```yaml
port: 8080
```
And update `settings.json`:
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:8080"
  }
}
```

**Add more models:**
Edit `copilot-config.yaml`:
```yaml
model_list:
  # ... existing models
  - model_name: gpt-4
    litellm_params:
      model: github_copilot/gpt-4
      drop_params: true
      extra_headers:
        Editor-Version: "vscode/1.85.1"
        Copilot-Integration-Id: "vscode-chat"
```

### 🚀 Pro Tips

1. **Run LiteLLM as a background service** (see [SETUP.md](docs/SETUP.md))
2. **Use `gpt-5.4` for fast operations** (set as `ANTHROPIC_SMALL_FAST_MODEL`)
3. **Use `claude-opus-4-5` for complex reasoning** (change `ANTHROPIC_MODEL`)
4. **Keep LiteLLM logs visible** to monitor requests
5. **Star the repo** if you find it useful! ⭐

---

## Common Commands Reference

### Start LiteLLM
```bash
# Mac/Linux
source litellm-keys.env && litellm --config copilot-config.yaml

# Windows
.\start-litellm.ps1
```

### Test Proxy
```bash
curl http://localhost:4000/health
```

### Check GitHub Auth
```bash
gh auth status
```

### View Available Models
```bash
curl http://localhost:4000/models
```

### Stop LiteLLM
Press `Ctrl+C` in the LiteLLM terminal

---

## Need Help?

- 📖 **Documentation:** [docs/](docs/)
- 🐛 **Issues:** [GitHub Issues](../../issues)
- 💬 **Discussions:** [GitHub Discussions](../../discussions)

---

**Happy coding with Claude Code + GitHub Copilot! 🚀**
