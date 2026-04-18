# Troubleshooting Guide

Solutions to common issues when using Claude Code with GitHub Copilot integration.

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Authentication Problems](#authentication-problems)
3. [Connection Errors](#connection-errors)
4. [Model Issues](#model-issues)
5. [Performance Problems](#performance-problems)
6. [Common Error Messages](#common-error-messages)

---

## Installation Issues

### Python/pip not found

**Symptom:**
```bash
bash: python3: command not found
bash: pip3: command not found
```

**Solution:**

**Mac:**
```bash
brew install python3
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install python3 python3-pip
```

**Windows:**
```powershell
winget install Python.Python.3.12
# Then restart terminal
```

### LiteLLM installation fails

**Symptom:**
```bash
ERROR: Could not find a version that satisfies the requirement litellm
```

**Solution:**
```bash
# Upgrade pip first
pip install --upgrade pip

# Try installing again
pip install 'litellm[proxy]'

# If still failing, use specific version
pip install 'litellm[proxy]==1.0.0'
```

### GitHub CLI not found

**Symptom:**
```bash
bash: gh: command not found
```

**Solution:**

**Mac:**
```bash
brew install gh
```

**Linux:**
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
sudo apt update
sudo apt install gh
```

**Windows:**
```powershell
winget install --id GitHub.cli
```

### setup.sh won't run (Windows)

**Symptom:**
```
'./setup.sh' is not recognized...
```

**Solution:**

**Option 1: Use Git Bash**
```bash
# In Git Bash
./setup.sh
```

**Option 2: Use WSL**
```bash
wsl
./setup.sh
```

**Option 3: Manual setup**
Follow the manual installation steps in [SETUP.md](SETUP.md).

---

## Authentication Problems

### GitHub authentication failed

**Symptom:**
```bash
gh: authentication required
```

**Solution:**

**1. Logout and login again:**
```bash
gh auth logout
gh auth login
```

**2. Choose correct options:**
- Select: **GitHub.com**
- Protocol: **HTTPS**
- Auth method: **Login with a web browser**

**3. Verify:**
```bash
gh auth status
```

Expected output:
```
✓ Logged in to github.com as <username>
✓ Git operations for github.com configured to use https protocol.
✓ Token: gho_****
✓ Token scopes: copilot, gist, read:org, repo, workflow
```

### Copilot not accessible

**Symptom:**
```bash
gh copilot explain "test"
# Error: Copilot is not enabled
```

**Solutions:**

**1. Verify subscription:**
- Go to [github.com/settings/copilot](https://github.com/settings/copilot)
- Check if Copilot is active
- If not, subscribe at [github.com/features/copilot/plans](https://github.com/features/copilot/plans)

**2. Wait for activation:**
- After subscribing, wait 5-10 minutes
- GitHub needs time to propagate access

**3. Re-authenticate:**
```bash
gh auth logout
gh auth login
```

**4. Check token scopes:**
```bash
gh auth status
```
Must include: `copilot` scope

### UUID mismatch errors

**Symptom:**
```
401 Unauthorized
Invalid API key
```

**Solution:**

**1. Verify UUIDs match:**
```bash
# Check litellm-keys.env
cat litellm-keys.env
# LITELLM_MASTER_KEY="litellm-abc123..."

# Check settings.json
cat settings.json
# "ANTHROPIC_AUTH_TOKEN": "litellm-abc123..."
```

**2. UUIDs must be identical:**
```bash
# Generate new UUID
python3 -c "import uuid; print('litellm-' + str(uuid.uuid4()))"

# Update BOTH files with same UUID
# litellm-keys.env: LITELLM_MASTER_KEY="litellm-<uuid>"
# settings.json: "ANTHROPIC_AUTH_TOKEN": "litellm-<uuid>"
```

**3. Reload environment:**
```bash
source litellm-keys.env

# Restart LiteLLM
litellm --config copilot-config.yaml
```

---

## Connection Errors

### Port 4000 already in use

**Symptom:**
```
ERROR: [Errno 48] Address already in use
```

**Solution:**

**1. Find what's using port 4000:**

**Mac/Linux:**
```bash
lsof -i :4000
# or
sudo netstat -tulpn | grep :4000
```

**Windows:**
```powershell
netstat -ano | findstr :4000
```

**2. Kill the process:**

**Mac/Linux:**
```bash
kill -9 <PID>
```

**Windows:**
```powershell
taskkill /PID <PID> /F
```

**3. Or use different port:**

Edit `copilot-config.yaml`:
```yaml
# Add at top
port: 8080

model_list:
  # ... models
```

Update `settings.json`:
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:8080"
  }
}
```

### Cannot connect to proxy

**Symptom:**
```
Failed to connect to localhost:4000
Connection refused
```

**Solution:**

**1. Check if LiteLLM is running:**
```bash
curl http://localhost:4000/health
```

**2. If not, start it:**
```bash
source litellm-keys.env
litellm --config copilot-config.yaml
```

**3. Check for startup errors:**
Look at LiteLLM terminal output for:
- Configuration errors
- Missing environment variables
- Port conflicts

**4. Verify environment variables loaded:**
```bash
echo $LITELLM_MASTER_KEY
echo $LITELLM_SALT_KEY
```

Should output: `litellm-<uuid>`

### Firewall blocking connection

**Symptom:**
```
Connection timeout
No route to host
```

**Solution:**

**Mac:**
```bash
# Allow LiteLLM through firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/bin/litellm
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblock /usr/local/bin/litellm
```

**Linux:**
```bash
# Allow port 4000 (if firewall enabled)
sudo ufw allow 4000/tcp
```

**Windows:**
```powershell
# Allow through Windows Firewall
New-NetFirewallRule -DisplayName "LiteLLM" -Direction Inbound -LocalPort 4000 -Protocol TCP -Action Allow
```

---

## Model Issues

### Model not found

**Symptom:**
```
Error: Model 'claude-sonnet-4-5' not found
```

**Solution:**

**1. Check model is in config:**
```bash
cat copilot-config.yaml
```

**2. Verify model name matches exactly:**
```yaml
model_list:
  - model_name: claude-sonnet-4-5  # Must match exactly
```

**3. List available models:**
```bash
curl http://localhost:4000/models
```

**4. Update settings.json to use valid model:**
```json
{
  "env": {
    "ANTHROPIC_MODEL": "claude-sonnet-4-5"  # Must match model_name
  }
}
```

### Model requests fail

**Symptom:**
```
Error calling model: 403 Forbidden
You do not have access to this model
```

**Solution:**

**1. Verify Copilot subscription includes model:**
Not all Copilot tiers have all models.

**2. Check GitHub Copilot access:**
```bash
gh copilot explain "test" --model "claude-sonnet-4.5"
```

**3. Try different model:**
```bash
# Test each model
curl -X POST http://localhost:4000/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5.4",
    "messages": [{"role": "user", "content": "Hi"}]
  }'
```

### Slow responses

**Symptom:**
- Requests take 30+ seconds
- Timeout errors

**Solution:**

**1. Use faster model:**
```json
{
  "env": {
    "ANTHROPIC_MODEL": "gpt-5.4"
  }
}
```

**2. Increase timeout:**
```json
{
  "env": {
    "ANTHROPIC_TIMEOUT": "120000"
  }
}
```

**3. Check network:**
```bash
ping github.com
# Should be < 100ms
```

**4. Restart LiteLLM:**
Sometimes proxy needs refresh.

---

## Performance Problems

### High memory usage

**Symptom:**
- LiteLLM using lots of RAM
- System slowdown

**Solution:**

**1. Disable caching:**
```yaml
litellm_settings:
  cache: false
```

**2. Limit concurrent requests:**
```yaml
litellm_settings:
  rpm: 10  # Requests per minute
```

**3. Restart proxy periodically:**
```bash
# Add to cron (Linux/Mac)
0 */6 * * * pkill -f litellm && litellm --config /path/to/config.yaml
```

### Claude Code freezes

**Symptom:**
- Claude Code stops responding
- Requests hang

**Solution:**

**1. Check LiteLLM is responding:**
```bash
curl http://localhost:4000/health
```

**2. Check LiteLLM logs:**
Look for errors in terminal.

**3. Restart both:**
```bash
# Stop LiteLLM (Ctrl+C)
# Restart it
source litellm-keys.env
litellm --config copilot-config.yaml

# Restart Claude Code
```

**4. Clear Claude Code cache:**
```bash
rm -rf ~/.claude/cache/
```

---

## Common Error Messages

### "Rate limit exceeded"

**Error:**
```json
{
  "error": {
    "message": "Rate limit exceeded",
    "type": "rate_limit_error"
  }
}
```

**Solution:**

**1. Wait a moment** - GitHub Copilot has rate limits

**2. Configure rate limiting:**
```yaml
litellm_settings:
  rpm: 60
  tpm: 100000
```

**3. Use different model:**
Different models have different limits.

### "Invalid configuration"

**Error:**
```
Error loading config: Invalid YAML syntax
```

**Solution:**

**1. Validate YAML:**
```bash
python3 -c "import yaml; yaml.safe_load(open('copilot-config.yaml'))"
```

**2. Check indentation:**
YAML requires consistent spacing (2 or 4 spaces, not tabs).

**3. Common issues:**
```yaml
# WRONG - mixing tabs and spaces
model_list:
	- model_name: gpt-5.4

# RIGHT - consistent spaces
model_list:
  - model_name: gpt-5.4
```

### "Environment variable not set"

**Error:**
```
KeyError: LITELLM_MASTER_KEY
```

**Solution:**

**1. Load environment:**
```bash
source litellm-keys.env
```

**2. Verify loaded:**
```bash
echo $LITELLM_MASTER_KEY
```

**3. Export manually if needed:**
```bash
export LITELLM_MASTER_KEY="litellm-your-uuid"
export LITELLM_SALT_KEY="litellm-your-uuid"
```

### "SSL certificate verify failed"

**Error:**
```
SSLError: certificate verify failed
```

**Solution:**

**1. Update certificates:**

**Mac:**
```bash
/Applications/Python\ 3.*/Install\ Certificates.command
```

**Linux:**
```bash
sudo apt install ca-certificates
sudo update-ca-certificates
```

**Windows:**
```powershell
pip install --upgrade certifi
```

**2. Temporarily disable SSL verification (not recommended):**
```bash
export CURL_CA_BUNDLE=""
export REQUESTS_CA_BUNDLE=""
```

---

## Debug Mode

### Enable verbose logging

**1. LiteLLM verbose mode:**
```yaml
litellm_settings:
  set_verbose: true
  json_logs: true
```

**2. Claude Code debug mode:**
```json
{
  "env": {
    "DEBUG": "true",
    "ANTHROPIC_LOG_LEVEL": "debug"
  }
}
```

**3. View logs:**
```bash
# LiteLLM logs (in terminal)
# Claude Code logs:
tail -f ~/.claude/logs/debug.log
```

### Test connectivity step-by-step

**1. Test local network:**
```bash
curl http://localhost:4000/health
```

**2. Test authentication:**
```bash
curl -H "Authorization: Bearer litellm-your-uuid" http://localhost:4000/models
```

**3. Test model call:**
```bash
curl -X POST http://localhost:4000/chat/completions \
  -H "Authorization: Bearer litellm-your-uuid" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5.4",
    "messages": [{"role": "user", "content": "test"}],
    "max_tokens": 10
  }'
```

**4. Test from Claude Code:**
Open Claude Code and type: "Hello"

---

## Getting Help

### Check logs

**LiteLLM:**
- Terminal output where you ran `litellm --config ...`

**Claude Code:**
```bash
# Mac/Linux
~/.claude/logs/

# Windows
%USERPROFILE%\.claude\logs\
```

### Collect diagnostic info

```bash
# System info
uname -a  # Mac/Linux
systeminfo  # Windows

# Python version
python3 --version

# LiteLLM version
pip show litellm

# GitHub CLI version
gh --version

# Network test
curl -v http://localhost:4000/health

# Process check
ps aux | grep litellm  # Mac/Linux
tasklist | findstr litellm  # Windows
```

### Report an issue

When opening a GitHub issue, include:

1. **Operating system** (Mac/Linux/Windows version)
2. **Python version**
3. **LiteLLM version**
4. **Error message** (full text)
5. **Steps to reproduce**
6. **Relevant logs** (redact UUIDs!)
7. **What you tried** (from this guide)

### Community support

- GitHub Issues: [Your repo issues page]
- Discord: [Your Discord link]
- Stack Overflow: Tag with `claude-code` and `github-copilot`

---

## Still Having Issues?

If none of these solutions work:

1. **Try clean reinstall:**
```bash
# Uninstall
pip uninstall litellm

# Remove config
rm -rf ~/.claude/

# Reinstall
pip install 'litellm[proxy]'
./setup.sh
```

2. **Check for updates:**
```bash
pip install --upgrade 'litellm[proxy]'
```

3. **Open an issue** with diagnostic info

---

**Most issues are solved by:**
- ✅ Matching UUIDs in both files
- ✅ Loading environment variables (`source litellm-keys.env`)
- ✅ Restarting LiteLLM after config changes
- ✅ Verifying GitHub Copilot subscription is active

Good luck! 🚀
