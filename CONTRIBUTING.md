# Contributing to Claude Code + GitHub Copilot Integration

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [How Can I Contribute?](#how-can-i-contribute)
3. [Development Setup](#development-setup)
4. [Coding Guidelines](#coding-guidelines)
5. [Pull Request Process](#pull-request-process)
6. [Testing](#testing)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive experience for everyone.

### Expected Behavior

- Be respectful and considerate
- Welcome newcomers
- Focus on what is best for the community
- Show empathy towards others

### Unacceptable Behavior

- Harassment, trolling, or discriminatory behavior
- Personal attacks
- Publishing others' private information
- Other conduct which could reasonably be considered inappropriate

---

## How Can I Contribute?

### Reporting Bugs

**Before submitting a bug report:**
1. Check the [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
2. Search existing [GitHub Issues](../../issues)
3. Check if it's already fixed in the latest version

**When submitting a bug report, include:**
- **Description:** Clear description of the bug
- **Steps to Reproduce:** Numbered steps to reproduce
- **Expected Behavior:** What should happen
- **Actual Behavior:** What actually happens
- **Environment:**
  - OS (Mac/Linux/Windows version)
  - Python version
  - LiteLLM version
  - Claude Code version
- **Logs:** Relevant error messages (redact UUIDs!)
- **Screenshots:** If applicable

**Bug Report Template:**
```markdown
## Description
Brief description of the bug

## Steps to Reproduce
1. First step
2. Second step
3. ...

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- OS: Windows 11
- Python: 3.11.5
- LiteLLM: 1.0.0
- Claude Code: 1.0.0

## Logs
```
Paste relevant logs here
```

## Screenshots
If applicable
```

### Suggesting Enhancements

We welcome feature suggestions!

**Before submitting:**
1. Check if it's already suggested in [Issues](../../issues)
2. Consider if it fits the project scope

**Include in your suggestion:**
- **Use Case:** Why do you need this feature?
- **Proposed Solution:** How should it work?
- **Alternatives:** Other ways to achieve this
- **Additional Context:** Screenshots, examples, etc.

### Documentation Improvements

Documentation improvements are always welcome!

**Areas to improve:**
- Fixing typos or unclear explanations
- Adding examples
- Improving setup instructions
- Adding troubleshooting tips
- Translating to other languages

**How to contribute:**
1. Fork the repository
2. Edit markdown files in `docs/`
3. Submit a pull request

### Code Contributions

We welcome code contributions!

**Good first issues:**
- Look for issues tagged `good first issue`
- Documentation improvements
- Adding tests
- Fixing minor bugs

---

## Development Setup

### 1. Fork and Clone

```bash
# Fork on GitHub, then:
git clone https://github.com/YOUR_USERNAME/claude-code-with-github-copilot.git
cd claude-code-with-github-copilot
```

### 2. Create Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

### 3. Install Development Dependencies

```bash
pip install -r requirements-dev.txt
```

### 4. Make Changes

Edit code, documentation, or configuration files.

### 5. Test Your Changes

```bash
# Test setup script
./setup.sh

# Test LiteLLM config
litellm --config copilot-config.yaml --test

# Run any tests
pytest tests/
```

### 6. Commit

```bash
git add .
git commit -m "feat: add new feature"
# or
git commit -m "fix: resolve bug in setup script"
```

**Commit Message Format:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Maintenance tasks

### 7. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

---

## Coding Guidelines

### Shell Scripts (setup.sh)

- Use `#!/bin/bash` shebang
- Set `set -e` for error handling
- Add comments for complex sections
- Use meaningful variable names
- Test on multiple platforms if possible

**Example:**
```bash
#!/bin/bash
set -e

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required"
    exit 1
fi
```

### PowerShell Scripts (setup.ps1)

- Use clear function names
- Include error handling with try/catch
- Add helpful output messages
- Test on Windows 10 and 11

**Example:**
```powershell
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
```

### YAML Configuration

- Use 2-space indentation
- Add comments for complex settings
- Validate YAML syntax before committing

**Example:**
```yaml
# Model configuration
model_list:
  # Fast model for quick operations
  - model_name: gpt-5.4
    litellm_params:
      model: github_copilot/gpt-5.4
```

### Documentation (Markdown)

- Use clear headings
- Include code examples
- Add tables of contents for long docs
- Test all command examples
- Keep line length reasonable (~80-100 chars)

**Example:**
```markdown
## Installation

### Prerequisites

Before installing, ensure you have:
- Python 3.8+
- GitHub CLI
- Active Copilot subscription

### Steps

1. Install LiteLLM:
   ```bash
   pip install 'litellm[proxy]'
   ```
```

---

## Pull Request Process

### Before Submitting

- [ ] Test your changes locally
- [ ] Update documentation if needed
- [ ] Add comments to complex code
- [ ] Ensure code follows style guidelines
- [ ] Commit messages follow convention
- [ ] Squash commits if necessary

### PR Description Template

```markdown
## Description
What does this PR do?

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Refactoring

## Related Issues
Fixes #123

## Testing
How did you test this?

## Screenshots
If applicable

## Checklist
- [ ] Code follows project style
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] All tests passing
```

### Review Process

1. **Automated Checks:** CI/CD runs tests
2. **Maintainer Review:** A maintainer reviews your code
3. **Feedback:** Address any requested changes
4. **Approval:** Once approved, it will be merged
5. **Release:** Included in next release

### After Merge

- Delete your branch (if comfortable)
- Check if it's in the next release
- Celebrate! 🎉

---

## Testing

### Manual Testing

**Test setup script:**
```bash
# On Mac/Linux
./setup.sh

# On Windows
.\setup.ps1
```

**Test LiteLLM:**
```bash
litellm --config copilot-config.yaml &
curl http://localhost:4000/health
```

**Test with Claude Code:**
1. Start LiteLLM
2. Launch Claude Code
3. Try various prompts
4. Check LiteLLM logs

### Automated Testing

If you add Python code, include tests:

```python
# tests/test_setup.py
def test_uuid_generation():
    uuid = generate_uuid()
    assert uuid.startswith("litellm-")
    assert len(uuid) == 44  # litellm- + 36 char UUID
```

Run tests:
```bash
pytest tests/
```

### Platform Testing

If possible, test on:
- [ ] macOS (latest)
- [ ] Linux (Ubuntu 20.04+)
- [ ] Windows 10
- [ ] Windows 11

---

## Code Review Guidelines

### For Contributors

**Respond to feedback:**
- Address all comments
- Ask questions if unclear
- Be open to suggestions

**Update your PR:**
```bash
git add .
git commit -m "fix: address review feedback"
git push origin your-branch
```

### For Reviewers

**Be constructive:**
- Explain why changes are needed
- Suggest alternatives
- Appreciate the contribution

**Review checklist:**
- [ ] Code is clear and maintainable
- [ ] Documentation is updated
- [ ] No security issues
- [ ] Tests are adequate
- [ ] Follows project conventions

---

## Release Process

### Versioning

We use [Semantic Versioning](https://semver.org/):
- **Major (1.0.0):** Breaking changes
- **Minor (0.1.0):** New features, backward compatible
- **Patch (0.0.1):** Bug fixes

### Release Checklist

1. Update version in relevant files
2. Update CHANGELOG.md
3. Create release tag
4. Update documentation
5. Announce on relevant channels

---

## Getting Help

### Questions

- Open a [GitHub Discussion](../../discussions)
- Ask in issues if it's a potential bug

### Stuck?

- Check [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
- Review [Architecture Documentation](docs/ARCHITECTURE.md)
- Ask for help in your PR comments

---

## Recognition

Contributors are recognized in:
- README.md (Contributors section)
- Release notes
- GitHub contributors page

Thank you for contributing! Every contribution, no matter how small, is valued and appreciated. 🙏

---

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).
