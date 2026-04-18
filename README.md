# Claude Code with GitHub Copilot Integration

Use Claude Code with GitHub Copilot's free LLM models (GPT-5.4, Claude Opus 4.5, Claude Sonnet 4.5) via LiteLLM proxy.

## 🚀 Quick Start

```bash
# 1. Clone and setup
git clone <your-repo-url>
cd claude-code-with-github-copilot

# 2. Run automated setup
./setup.sh
```

That's it! The setup script will guide you through the entire process.

## 📋 What This Does

This integration lets you:
- ✅ Use GitHub Copilot's LLM models with Claude Code
- ✅ Access GPT-5.4, Claude Opus 4.5, and Claude Sonnet 4.5 for free (with Copilot subscription)
- ✅ Configure Claude Code to route requests through LiteLLM proxy
- ✅ Leverage GitHub Copilot's API without additional costs

## 📦 Prerequisites

- **GitHub Copilot Subscription** (Individual, Business, or Enterprise)
- **GitHub CLI** (`gh`) - [Install Guide](https://cli.github.com/)
- **Python 3.8+** with pip
- **Claude Code** - [Download](https://claude.com/claude-code)

## 🛠️ Manual Installation

If you prefer manual setup or the automated script doesn't work:

### 1. Install LiteLLM

```bash
pip install 'litellm[proxy]'
```

### 2. Configure Environment Variables

Edit `litellm-keys.env`:
```bash
LITELLM_MASTER_KEY="litellm-your-uuid-here"
LITELLM_SALT_KEY="litellm-your-uuid-here"
```

Generate UUIDs:
```bash
# Linux/Mac
uuidgen

# Python (cross-platform)
python -c "import uuid; print('litellm-' + str(uuid.uuid4()))"
```

### 3. Update Settings

Edit `settings.json` with the **same UUID** as master key:
```json
{
  "autoUpdatesChannel": "latest",
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "litellm-your-uuid-here",
    "ANTHROPIC_BASE_URL": "http://localhost:4000",
    "ANTHROPIC_MODEL": "claude-sonnet-4-5",
    "ANTHROPIC_SMALL_FAST_MODEL": "gpt-5.4"
  }
}
```

### 4. Load Environment Variables

```bash
# Linux/Mac
source litellm-keys.env

# Windows (PowerShell)
Get-Content litellm-keys.env | ForEach-Object { 
  $var = $_.Split('='); 
  [Environment]::SetEnvironmentVariable($var[0], $var[1].Trim('"'), "Process") 
}

# Windows (CMD)
for /f "tokens=1,2 delims==" %a in (litellm-keys.env) do set %a=%b
```

### 5. Start LiteLLM Proxy

```bash
litellm --config copilot-config.yaml
```

You should see:
```
INFO: Uvicorn running on http://0.0.0.0:4000
```

### 6. Test the Proxy

In a new terminal:
```bash
curl --location 'http://0.0.0.0:4000/chat/completions' \
  --header 'Content-Type: application/json' \
  --header 'Editor-Version: CommandLine/1.0' \
  --data '{
    "model": "gpt-5.4",
    "messages": [
      {
        "role": "user",
        "content": "what llm are you"
      }
    ]
  }'
```

### 7. Configure Claude Code

Copy `settings.json` to your Claude Code configuration:

**Location depends on your setup:**
- Project-level: `.claude/settings.json` (in your project)
- User-level: 
  - Mac: `~/.claude/settings.json`
  - Linux: `~/.claude/settings.json`
  - Windows: `%USERPROFILE%\.claude\settings.json`

```bash
# Project-level (recommended for testing)
mkdir -p .claude
cp settings.json .claude/settings.json

# User-level (applies to all projects)
cp settings.json ~/.claude/settings.json  # Mac/Linux
copy settings.json %USERPROFILE%\.claude\settings.json  # Windows
```

### 8. Test Claude Code

Launch Claude Code and verify it's using the LiteLLM proxy. You should see requests being logged in the LiteLLM terminal.

## 📚 Documentation

- [Detailed Setup Guide](docs/SETUP.md)
- [Configuration Options](docs/CONFIGURATION.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Architecture & How It Works](docs/ARCHITECTURE.md)

## 🔧 Configuration

### Available Models

Edit `copilot-config.yaml` to customize:
- `gpt-5.4` - Fast, powerful GPT model
- `claude-opus-4-5` - Most capable Claude model
- `claude-sonnet-4-5` - Balanced performance/speed

### Claude Code Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `ANTHROPIC_AUTH_TOKEN` | LiteLLM master key | `litellm-your-uuid` |
| `ANTHROPIC_BASE_URL` | LiteLLM proxy URL | `http://localhost:4000` |
| `ANTHROPIC_MODEL` | Default model | `claude-sonnet-4-5` |
| `ANTHROPIC_SMALL_FAST_MODEL` | Fast model for quick tasks | `gpt-5.4` |

## 🐛 Troubleshooting

### LiteLLM won't start
```bash
# Check if port 4000 is already in use
lsof -i :4000  # Mac/Linux
netstat -ano | findstr :4000  # Windows

# Kill existing process or change port in copilot-config.yaml
```

### Authentication errors
```bash
# Re-authenticate GitHub CLI
gh auth logout
gh auth login

# Verify authentication
gh auth status
```

### Claude Code can't connect
1. Verify LiteLLM is running: `curl http://localhost:4000/health`
2. Check UUID matches in `litellm-keys.env` and `settings.json`
3. Restart Claude Code after updating settings

See [Troubleshooting Guide](docs/TROUBLESHOOTING.md) for more solutions.

## 🤝 Contributing

Contributions welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) first.

## 📄 License

[MIT License](LICENSE)

## 🔗 Links

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [LiteLLM Documentation](https://docs.litellm.ai/)
- [GitHub Copilot](https://github.com/features/copilot)
- [GitHub CLI](https://cli.github.com/)
- [anderssv Guide](https://blog.f12.no/wp/2025/09/22/using-claude-code-with-github-copilot-a-guide/)

## ⭐ Star History

If you find this useful, please star the repository!

## 💡 Tips

- Use `claude-sonnet-4-5` as default for best balance
- Use `gpt-5.4` for fast operations (file searches, quick edits)
- Use `claude-opus-4-5` for complex reasoning tasks
- Keep LiteLLM proxy running in a dedicated terminal or as a service
- Monitor LiteLLM logs to see which models are being used

## 🚦 Status

Current Status: **Active Development**

Tested with:
- Claude Code: v1.0+
- LiteLLM: v1.0+
- GitHub Copilot: Current subscription models
