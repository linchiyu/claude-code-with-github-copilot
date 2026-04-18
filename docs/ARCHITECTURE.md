# Architecture & How It Works

Understand the technical architecture of Claude Code + GitHub Copilot integration.

## Table of Contents

1. [Overview](#overview)
2. [Architecture Diagram](#architecture-diagram)
3. [Component Details](#component-details)
4. [Request Flow](#request-flow)
5. [Authentication](#authentication)
6. [Model Routing](#model-routing)
7. [Security Considerations](#security-considerations)

---

## Overview

This integration allows Claude Code to use GitHub Copilot's LLM models by proxying requests through LiteLLM, which translates between Claude Code's API format and GitHub Copilot's API.

### Key Components

1. **Claude Code** - The AI coding assistant client
2. **LiteLLM Proxy** - Translation layer and router
3. **GitHub Copilot** - Provider of LLM models (GPT-5.4, Claude models)
4. **GitHub CLI (gh)** - Authentication handler

---

## Architecture Diagram

```
┌─────────────────┐
│   Claude Code   │
│   (Client)      │
└────────┬────────┘
         │ ANTHROPIC_BASE_URL
         │ http://localhost:4000
         │
         ▼
┌─────────────────────────────┐
│   LiteLLM Proxy             │
│   ┌─────────────────────┐   │
│   │ Request Translator  │   │
│   ├─────────────────────┤   │
│   │ Model Router        │   │
│   ├─────────────────────┤   │
│   │ Auth Handler        │   │
│   └─────────────────────┘   │
└────────┬────────────────────┘
         │ github_copilot/*
         │
         ▼
┌─────────────────────────────┐
│   GitHub CLI (gh)           │
│   ┌─────────────────────┐   │
│   │ OAuth Token Manager │   │
│   └─────────────────────┘   │
└────────┬────────────────────┘
         │ Authenticated requests
         │
         ▼
┌─────────────────────────────┐
│   GitHub Copilot API        │
│   ┌──────┬──────┬──────┐    │
│   │GPT   │Claude│ o1   │    │
│   │5.4   │ 4.5  │preview│   │
│   └──────┴──────┴──────┘    │
└─────────────────────────────┘
```

---

## Component Details

### Claude Code

**Role:** AI coding assistant client

**Configuration:**
- `ANTHROPIC_BASE_URL`: Points to LiteLLM (not actual Anthropic API)
- `ANTHROPIC_AUTH_TOKEN`: LiteLLM master key (not Anthropic API key)
- `ANTHROPIC_MODEL`: Default model name from LiteLLM config

**What it does:**
1. User types a request
2. Sends HTTP POST to `ANTHROPIC_BASE_URL/v1/messages`
3. Includes `ANTHROPIC_AUTH_TOKEN` as Bearer token
4. Receives streaming response

**API Format:**
```bash
POST http://localhost:4000/v1/messages
Authorization: Bearer litellm-uuid

{
  "model": "claude-sonnet-4-5",
  "messages": [
    {"role": "user", "content": "Hello"}
  ],
  "max_tokens": 4096,
  "stream": true
}
```

### LiteLLM Proxy

**Role:** Translation and routing layer

**What it does:**

1. **Receives requests** from Claude Code
2. **Validates** auth token (UUID)
3. **Translates** Anthropic API format → provider format
4. **Routes** to appropriate backend (GitHub Copilot)
5. **Streams** response back to Claude Code

**Configuration File:** `copilot-config.yaml`

**Key Features:**
- **Model routing** - Maps model names to backends
- **Request translation** - Converts API formats
- **Parameter filtering** - Removes unsupported params (`drop_params: true`)
- **Header injection** - Adds required headers for GitHub
- **Fallback handling** - Retries with backup models
- **Rate limiting** - Throttles requests if configured

**Translation Example:**

Claude Code sends:
```json
{
  "model": "claude-sonnet-4-5",
  "messages": [...],
  "max_tokens": 4096
}
```

LiteLLM translates to:
```json
{
  "model": "github_copilot/claude-sonnet-4.5",
  "messages": [...],
  "max_tokens": 4096,
  "extra_headers": {
    "Editor-Version": "vscode/1.85.1",
    "Copilot-Integration-Id": "vscode-chat"
  }
}
```

### GitHub CLI (gh)

**Role:** Authentication provider

**What it does:**

1. **Stores** GitHub OAuth token
2. **Provides** token to LiteLLM when needed
3. **Refreshes** token automatically when expired

**Authentication Flow:**
```bash
gh auth login
# → Opens browser
# → User logs into GitHub
# → Grants Copilot permissions
# → Token stored in ~/.config/gh/hosts.yml
```

**Token Storage:**
```yaml
# ~/.config/gh/hosts.yml
github.com:
    oauth_token: gho_xxxxxxxxxxxxxxxxxxxx
    user: username
```

### GitHub Copilot API

**Role:** LLM model provider

**Available Models:**
- `gpt-5.4` - OpenAI's latest fast model
- `claude-opus-4.5` - Anthropic's most capable
- `claude-sonnet-4.5` - Anthropic's balanced model
- `gpt-4` - OpenAI GPT-4
- `o1-preview` - OpenAI's reasoning model

**Rate Limits:**
- Varies by subscription tier
- Typically 60-100 requests/minute
- Token limits per request

---

## Request Flow

### Detailed Step-by-Step

```
1. User types in Claude Code
   ↓
2. Claude Code → POST /v1/messages
   Headers:
     Authorization: Bearer litellm-abc123
     Content-Type: application/json
   Body:
     {"model": "claude-sonnet-4-5", "messages": [...]}
   ↓
3. LiteLLM receives request
   ↓
4. LiteLLM validates auth token
   - Checks if "litellm-abc123" matches LITELLM_MASTER_KEY
   - If invalid: 401 Unauthorized
   - If valid: continue
   ↓
5. LiteLLM looks up model
   - Finds "claude-sonnet-4-5" in model_list
   - Gets backend: "github_copilot/claude-sonnet-4.5"
   ↓
6. LiteLLM translates request
   - Converts Anthropic API → GitHub Copilot API
   - Adds extra headers
   - Filters unsupported params
   ↓
7. LiteLLM → GitHub Copilot API
   Headers:
     Authorization: Bearer gho_xxx (from gh)
     Editor-Version: vscode/1.85.1
     Copilot-Integration-Id: vscode-chat
   Body:
     {"model": "claude-sonnet-4.5", "messages": [...]}
   ↓
8. GitHub validates gh token
   - Checks subscription status
   - Verifies model access
   ↓
9. GitHub → Anthropic API (for Claude models)
   or OpenAI API (for GPT models)
   ↓
10. Model generates response
    ↓
11. Response streams back:
    Anthropic → GitHub → LiteLLM → Claude Code
    ↓
12. Claude Code displays response to user
```

### Timing

| Step | Typical Latency |
|------|----------------|
| Claude Code → LiteLLM | <10ms |
| LiteLLM validation | <5ms |
| LiteLLM translation | <5ms |
| LiteLLM → GitHub | 50-100ms |
| GitHub → Model API | 100-500ms |
| Model first token | 500-2000ms |
| Model streaming | 20-50 tokens/sec |

**Total time to first token:** ~1-3 seconds

---

## Authentication

### Three-Layer Auth

```
Layer 1: Claude Code → LiteLLM
   Token: litellm-<uuid> (LITELLM_MASTER_KEY)
   Type: Bearer token
   Purpose: Access control for LiteLLM

Layer 2: LiteLLM → GitHub
   Token: gho_xxx (from gh auth)
   Type: OAuth token
   Purpose: GitHub authentication

Layer 3: GitHub → Model Provider
   Token: GitHub's internal tokens
   Type: API keys
   Purpose: Access model APIs
```

### Security Flow

```
┌──────────────┐
│ Claude Code  │
│ Has: UUID    │
└──────┬───────┘
       │
       │ litellm-abc123
       │
       ▼
┌──────────────────────┐
│ LiteLLM Proxy        │
│ Validates: UUID      │
│ Has: gh token        │
└──────┬───────────────┘
       │
       │ gho_xxx
       │
       ▼
┌──────────────────────┐
│ GitHub Copilot       │
│ Validates: gh token  │
│ Checks: subscription │
└──────┬───────────────┘
       │
       │ Internal tokens
       │
       ▼
┌──────────────────────┐
│ Model APIs           │
│ (Anthropic, OpenAI)  │
└──────────────────────┘
```

### Token Lifecycle

**LiteLLM UUID:**
- Generated once during setup
- Never expires
- Stored in: `litellm-keys.env` and `settings.json`
- Can be rotated anytime

**GitHub OAuth Token:**
- Created during `gh auth login`
- Expires: ~1 year
- Auto-refreshed by `gh`
- Stored in: `~/.config/gh/hosts.yml`

---

## Model Routing

### How LiteLLM Chooses Models

```yaml
model_list:
  - model_name: fast           # Display name
    litellm_params:
      model: github_copilot/gpt-5.4  # Backend
      
  - model_name: smart
    litellm_params:
      model: github_copilot/claude-opus-4.5
      fallbacks: ["github_copilot/claude-sonnet-4.5"]
```

**Routing Logic:**

1. **Exact match:** If request says `fast`, use first model
2. **Fallback:** If first fails, try fallback models
3. **Round-robin:** Multiple models with same name → load balance
4. **Custom routing:** Can add routing strategies

### Model Aliases

You can create aliases:

```yaml
model_list:
  # Main models
  - model_name: claude-sonnet-4-5
    litellm_params:
      model: github_copilot/claude-sonnet-4.5
      
  # Alias
  - model_name: sonnet
    litellm_params:
      model: github_copilot/claude-sonnet-4.5
```

Now both names work:
```json
{"model": "claude-sonnet-4-5"}  // Works
{"model": "sonnet"}              // Also works
```

### Load Balancing

```yaml
model_list:
  - model_name: balanced
    litellm_params:
      model: github_copilot/gpt-5.4
      
  - model_name: balanced
    litellm_params:
      model: github_copilot/claude-sonnet-4.5

# Requests to "balanced" alternate between models
```

---

## Security Considerations

### What's Protected

✅ **Your UUID** (LITELLM_MASTER_KEY)
- Only on your machine
- Not sent to GitHub or model providers
- Controls access to your LiteLLM proxy

✅ **Your gh token** (OAuth)
- Only on your machine
- Encrypted in keychain (Mac) or credential manager (Windows)
- Only sent to GitHub (HTTPS)

✅ **Your requests**
- End-to-end HTTPS after leaving localhost
- Not logged by GitHub (per Copilot privacy policy)

### What's Exposed

⚠️ **To GitHub:**
- That you're using Copilot (expected)
- Model usage patterns
- Request metadata (not content)

⚠️ **To Model Providers:**
- Your prompts (if using Claude/GPT models)
- Per Copilot's privacy policy with providers

### Best Practices

**1. Keep UUID secret:**
```bash
# Add to .gitignore
litellm-keys.env
.claude/settings.json
```

**2. Use localhost only:**
```yaml
# copilot-config.yaml
host: 127.0.0.1  # Not 0.0.0.0
```

**3. Rotate UUID periodically:**
```bash
# Generate new UUID
python3 -c "import uuid; print('litellm-' + str(uuid.uuid4()))"

# Update both files
# Restart LiteLLM and Claude Code
```

**4. Monitor access:**
```yaml
# Enable logging
litellm_settings:
  set_verbose: true
  json_logs: true
```

**5. Firewall rules:**
```bash
# Only allow localhost
sudo ufw deny 4000
sudo ufw allow from 127.0.0.1 to any port 4000
```

---

## Data Flow

### What Data Goes Where

```
Your Machine:
  Claude Code → [Prompt] → LiteLLM
  
Your Machine:
  LiteLLM → [Translated Prompt + gh token] → GitHub
  
GitHub's Servers:
  GitHub → [Prompt] → Model Provider (Anthropic/OpenAI)
  
Model Provider:
  Process prompt → Generate response
  
GitHub's Servers:
  GitHub ← [Response] ← Model Provider
  
Your Machine:
  LiteLLM ← [Response] ← GitHub
  
Your Machine:
  Claude Code ← [Response] ← LiteLLM
```

### What's Stored

**On your machine:**
- LiteLLM logs (if enabled)
- Claude Code conversation history
- Configuration files

**On GitHub servers:**
- Usage telemetry (anonymous)
- Rate limiting counters
- Audit logs (for enterprise)

**On model provider servers:**
- Per their privacy policy
- Typically: temporarily for processing, not for training (per Copilot agreement)

---

## Performance Characteristics

### Latency Breakdown

For a typical request:

```
User types                                    0ms
  ↓
Claude Code processing                      +10ms
  ↓
Network (local)                             +2ms
  ↓
LiteLLM validation & translation            +8ms
  ↓
Network (to GitHub)                         +100ms
  ↓
GitHub routing                              +50ms
  ↓
Network (to model provider)                 +100ms
  ↓
Model processing (first token)              +1000ms
  ↓
Stream back (per token)                     +20ms/token
═══════════════════════════════════════════════
Total to first token                        ~1270ms
Total for 100-token response                ~3270ms
```

### Bottlenecks

1. **Model processing** - 70% of latency
2. **Network to GitHub** - 15% of latency
3. **GitHub routing** - 10% of latency
4. **Local processing** - 5% of latency

### Optimization

**Use faster model for quick tasks:**
```json
{
  "env": {
    "ANTHROPIC_SMALL_FAST_MODEL": "gpt-5.4"  // 2x faster
  }
}
```

**Enable streaming:**
Perceive responses faster even if total time is same.

**Reduce max_tokens:**
Shorter responses = less time.

---

## Comparison to Direct APIs

### This Setup vs Direct Anthropic

| Aspect | This Setup | Direct Anthropic |
|--------|-----------|------------------|
| **Cost** | Free* | $15-75/month |
| **Latency** | +100ms (GitHub hop) | Faster |
| **Rate limits** | Copilot limits | API limits |
| **Models** | Copilot selection | All Anthropic models |
| **Setup** | More complex | Simpler |

*With Copilot subscription

### This Setup vs Direct Copilot

You **cannot** use Copilot models directly with Claude Code (different API formats). This setup is the bridge.

---

## Technical Specs

### System Requirements

**Minimum:**
- CPU: 1 core
- RAM: 512MB (for LiteLLM)
- Disk: 100MB
- Network: 1 Mbps

**Recommended:**
- CPU: 2+ cores
- RAM: 1GB
- Disk: 500MB
- Network: 10+ Mbps

### Port Usage

| Component | Port | Protocol | Scope |
|-----------|------|----------|-------|
| LiteLLM | 4000 | HTTP | localhost |
| Claude Code | - | HTTP client | - |

### Protocols

- **Claude Code ↔ LiteLLM:** HTTP/1.1, SSE (streaming)
- **LiteLLM ↔ GitHub:** HTTPS/2
- **GitHub ↔ Models:** HTTPS/2

---

## Extensibility

### Adding New Models

```yaml
model_list:
  # Add any GitHub Copilot model
  - model_name: my-new-model
    litellm_params:
      model: github_copilot/new-model-name
      drop_params: true
      extra_headers:
        Editor-Version: "vscode/1.85.1"
        Copilot-Integration-Id: "vscode-chat"
```

### Adding Other Providers

LiteLLM supports 100+ providers:

```yaml
model_list:
  # Use GitHub Copilot
  - model_name: copilot-gpt
    litellm_params:
      model: github_copilot/gpt-5.4
      
  # Also use OpenAI directly (if you have API key)
  - model_name: openai-gpt4
    litellm_params:
      model: gpt-4
      api_key: sk-xxx
```

### Custom Middleware

LiteLLM supports callbacks:

```python
# custom_callback.py
def request_callback(kwargs):
    print(f"Request to {kwargs['model']}")
    return kwargs

def success_callback(kwargs, response):
    print(f"Success: {response.usage}")
```

```yaml
litellm_settings:
  success_callback: ["custom_callback.success_callback"]
```

---

## Future Improvements

Potential enhancements:

1. **Auto-update models** - Detect new Copilot models
2. **Smart routing** - Route by prompt complexity
3. **Cost tracking** - Monitor Copilot usage
4. **Model benchmarking** - Compare quality/speed
5. **GUI config** - Web UI for settings

---

## Learn More

- [LiteLLM Docs](https://docs.litellm.ai/)
- [GitHub Copilot API](https://docs.github.com/en/copilot)
- [Claude Code Docs](https://docs.anthropic.com/claude-code)

---

**Questions about architecture?** Open a GitHub issue!
