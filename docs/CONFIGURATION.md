# Configuration Options

Complete reference for customizing your Claude Code + GitHub Copilot setup.

## Table of Contents

1. [LiteLLM Configuration](#litellm-configuration)
2. [Claude Code Settings](#claude-code-settings)
3. [Model Selection](#model-selection)
4. [Advanced Options](#advanced-options)
5. [Performance Tuning](#performance-tuning)

---

## LiteLLM Configuration

### copilot-config.yaml

#### Basic Structure

```yaml
model_list:
  - model_name: <display-name>
    litellm_params:
      model: github_copilot/<actual-model>
      drop_params: true
      extra_headers:
        Editor-Version: "vscode/1.85.1"
        Copilot-Integration-Id: "vscode-chat"
```

#### Available Models

| Display Name | Actual Model | Best For |
|-------------|--------------|----------|
| `gpt-5.4` | `github_copilot/gpt-5.4` | Fast operations, code completion |
| `claude-opus-4-5` | `github_copilot/claude-opus-4.5` | Complex reasoning, analysis |
| `claude-sonnet-4-5` | `github_copilot/claude-sonnet-4.5` | Balanced performance |
| `gpt-4` | `github_copilot/gpt-4` | General purpose |
| `o1-preview` | `github_copilot/o1-preview` | Advanced reasoning |

#### Add More Models

```yaml
model_list:
  # Existing models...
  
  - model_name: gpt-4
    litellm_params:
      model: github_copilot/gpt-4
      drop_params: true
      extra_headers:
        Editor-Version: "vscode/1.85.1"
        Copilot-Integration-Id: "vscode-chat"
        
  - model_name: o1-preview
    litellm_params:
      model: github_copilot/o1-preview
      drop_params: true
      extra_headers:
        Editor-Version: "vscode/1.85.1"
        Copilot-Integration-Id: "vscode-chat"
```

#### Change Port

```yaml
# Add at top level (before model_list)
port: 8080

model_list:
  # ... your models
```

Then update `settings.json`:
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:8080"
  }
}
```

#### Enable Logging

```yaml
# Add at top level
general_settings:
  master_key: ${LITELLM_MASTER_KEY}
  
litellm_settings:
  set_verbose: true
  json_logs: true
  
model_list:
  # ... your models
```

#### Rate Limiting

```yaml
general_settings:
  master_key: ${LITELLM_MASTER_KEY}
  
litellm_settings:
  rpm: 60  # Requests per minute
  tpm: 1000000  # Tokens per minute
  
model_list:
  # ... your models
```

#### Caching

```yaml
litellm_settings:
  cache: true
  cache_params:
    type: "redis"
    host: "localhost"
    port: 6379
    
model_list:
  # ... your models
```

---

## Claude Code Settings

### settings.json Reference

#### Minimal Configuration

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "litellm-your-uuid",
    "ANTHROPIC_BASE_URL": "http://localhost:4000"
  }
}
```

#### Full Configuration

```json
{
  "autoUpdatesChannel": "latest",
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "litellm-your-uuid",
    "ANTHROPIC_BASE_URL": "http://localhost:4000",
    "ANTHROPIC_MODEL": "claude-sonnet-4-5",
    "ANTHROPIC_SMALL_FAST_MODEL": "gpt-5.4",
    "ANTHROPIC_TIMEOUT": "120000",
    "ANTHROPIC_MAX_RETRIES": "3"
  },
  "maxFileSize": 1048576,
  "theme": "dark"
}
```

#### Environment Variables

| Variable | Description | Default | Valid Values |
|----------|-------------|---------|--------------|
| `ANTHROPIC_AUTH_TOKEN` | **Required**. Must match `LITELLM_MASTER_KEY` | None | `litellm-<uuid>` |
| `ANTHROPIC_BASE_URL` | **Required**. LiteLLM proxy URL | None | `http://localhost:4000` |
| `ANTHROPIC_MODEL` | Default model for main operations | `claude-3-5-sonnet-20241022` | Any model in config |
| `ANTHROPIC_SMALL_FAST_MODEL` | Model for quick operations | Same as above | Any model in config |
| `ANTHROPIC_TIMEOUT` | Request timeout in ms | `60000` | `10000-300000` |
| `ANTHROPIC_MAX_RETRIES` | Retry failed requests | `2` | `0-5` |

#### Settings Locations

**Priority order (first found wins):**

1. **Project-level:** `.claude/settings.json` (in project root)
2. **User-level:** `~/.claude/settings.json`
3. **System-level:** `/etc/claude/settings.json` (Linux only)

**Recommendation:**
- Use **project-level** for project-specific configs
- Use **user-level** for global preferences

#### Multiple Profiles

Create different settings for different use cases:

**Development profile:**
```json
{
  "env": {
    "ANTHROPIC_MODEL": "gpt-5.4",
    "ANTHROPIC_TIMEOUT": "30000"
  }
}
```

**Production profile:**
```json
{
  "env": {
    "ANTHROPIC_MODEL": "claude-opus-4-5",
    "ANTHROPIC_TIMEOUT": "120000"
  }
}
```

Switch by copying the desired profile to `.claude/settings.json`.

---

## Model Selection

### When to Use Each Model

#### gpt-5.4
**Best for:**
- ✅ Fast code completion
- ✅ Quick edits and refactoring
- ✅ File searches
- ✅ Simple Q&A
- ✅ Repetitive tasks

**Not ideal for:**
- ❌ Complex reasoning
- ❌ Long-form content
- ❌ Nuanced analysis

**Cost:** Lowest token usage

#### claude-sonnet-4-5
**Best for:**
- ✅ Balanced performance/speed
- ✅ Most general use cases
- ✅ Code reviews
- ✅ Documentation
- ✅ Bug fixing

**Not ideal for:**
- ❌ Ultra-fast responses needed
- ❌ Highly complex reasoning

**Cost:** Medium token usage

#### claude-opus-4-5
**Best for:**
- ✅ Complex problem solving
- ✅ Architecture design
- ✅ In-depth analysis
- ✅ Research tasks
- ✅ Critical decisions

**Not ideal for:**
- ❌ Simple tasks (overkill)
- ❌ Speed-critical operations

**Cost:** Highest token usage

### Recommended Configurations

#### Speed-focused
```json
{
  "env": {
    "ANTHROPIC_MODEL": "gpt-5.4",
    "ANTHROPIC_SMALL_FAST_MODEL": "gpt-5.4"
  }
}
```

#### Balanced (Recommended)
```json
{
  "env": {
    "ANTHROPIC_MODEL": "claude-sonnet-4-5",
    "ANTHROPIC_SMALL_FAST_MODEL": "gpt-5.4"
  }
}
```

#### Quality-focused
```json
{
  "env": {
    "ANTHROPIC_MODEL": "claude-opus-4-5",
    "ANTHROPIC_SMALL_FAST_MODEL": "claude-sonnet-4-5"
  }
}
```

---

## Advanced Options

### Custom Model Routing

Route different operations to different models:

```yaml
# copilot-config.yaml
router_settings:
  routing_strategy: "simple-shuffle"
  allowed_fails: 3
  
model_list:
  # Fast model for simple tasks
  - model_name: fast
    litellm_params:
      model: github_copilot/gpt-5.4
      
  # Smart model for complex tasks  
  - model_name: smart
    litellm_params:
      model: github_copilot/claude-opus-4.5
```

### Fallback Models

```yaml
model_list:
  - model_name: primary
    litellm_params:
      model: github_copilot/claude-sonnet-4.5
      fallbacks: ["github_copilot/gpt-5.4"]
```

### Request Throttling

```yaml
litellm_settings:
  request_timeout: 600
  num_retries: 3
  allowed_fails: 10
  cooldown_time: 0.1
```

### Custom Headers

```yaml
model_list:
  - model_name: custom
    litellm_params:
      model: github_copilot/gpt-5.4
      extra_headers:
        Editor-Version: "custom/2.0"
        Copilot-Integration-Id: "custom-integration"
        X-Custom-Header: "value"
```

---

## Performance Tuning

### Reduce Latency

**1. Use fastest model for SMALL_FAST:**
```json
{
  "env": {
    "ANTHROPIC_SMALL_FAST_MODEL": "gpt-5.4"
  }
}
```

**2. Reduce timeout:**
```json
{
  "env": {
    "ANTHROPIC_TIMEOUT": "30000"
  }
}
```

**3. Local network only:**
```yaml
# copilot-config.yaml
host: 127.0.0.1  # Don't listen on all interfaces
port: 4000
```

### Optimize Token Usage

**1. Enable streaming:**
```yaml
litellm_settings:
  stream_response: true
```

**2. Set max tokens:**
```yaml
model_list:
  - model_name: gpt-5.4
    litellm_params:
      model: github_copilot/gpt-5.4
      max_tokens: 4096  # Limit response size
```

### Monitor Performance

**Enable metrics:**
```yaml
general_settings:
  master_key: ${LITELLM_MASTER_KEY}
  database_url: "postgresql://..."  # Optional: Persist metrics
  
litellm_settings:
  success_callback: ["prometheus"]
  failure_callback: ["prometheus"]
```

**View metrics:**
```bash
curl http://localhost:4000/metrics
```

### Debug Issues

**1. Enable verbose logging:**
```yaml
litellm_settings:
  set_verbose: true
  json_logs: true
```

**2. Check logs:**
```bash
# See LiteLLM terminal output
# Or if running as service:
journalctl -u litellm -f  # Linux
tail -f /var/log/litellm.log  # Mac
```

**3. Test individual models:**
```bash
curl -X POST http://localhost:4000/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer litellm-your-uuid" \
  -d '{
    "model": "gpt-5.4",
    "messages": [{"role": "user", "content": "test"}],
    "stream": false
  }'
```

---

## Environment-Specific Configs

### Development

```json
{
  "env": {
    "ANTHROPIC_MODEL": "gpt-5.4",
    "ANTHROPIC_TIMEOUT": "30000",
    "DEBUG": "true"
  }
}
```

### Production

```json
{
  "env": {
    "ANTHROPIC_MODEL": "claude-sonnet-4-5",
    "ANTHROPIC_TIMEOUT": "120000",
    "ANTHROPIC_MAX_RETRIES": "5"
  }
}
```

### Testing

```json
{
  "env": {
    "ANTHROPIC_MODEL": "gpt-5.4",
    "ANTHROPIC_TIMEOUT": "10000",
    "MOCK_RESPONSES": "true"
  }
}
```

---

## Security Considerations

### Protect Your UUIDs

**Never commit:**
```bash
# Add to .gitignore
litellm-keys.env
.claude/settings.json
settings.local.json
```

**Use environment variables:**
```yaml
# copilot-config.yaml
general_settings:
  master_key: ${LITELLM_MASTER_KEY}  # Reference env var
```

### Network Security

**Bind to localhost only:**
```yaml
host: 127.0.0.1  # Not 0.0.0.0
port: 4000
```

**Use HTTPS (production):**
```yaml
ssl_keyfile: /path/to/key.pem
ssl_certfile: /path/to/cert.pem
```

---

## Next Steps

- Check [Troubleshooting](TROUBLESHOOTING.md) for common issues
- Read [Architecture](ARCHITECTURE.md) to understand how it works
- Return to [Setup Guide](SETUP.md) for installation help

---

**Questions?** Open an issue on GitHub!
