# Contributing to mac-dev-setup

Thank you for your interest in contributing! This project aims to be a robust, well-tested setup for macOS development environments.

## Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Test your changes (see Testing section)
5. Submit a pull request

## Testing

Before submitting changes:

```bash
# Run shell linting
shellcheck *.sh tasks/*.sh scripts/*.sh

# Test Brewfile
brew bundle --dry-run

# Test install script (in a safe environment)
./install.sh --dry-run
```

## Code Standards

- Use `set -euo pipefail` in all shell scripts
- Follow existing code style and naming conventions
- Add comments for complex logic
- Update documentation for user-facing changes

## What to Contribute

- **Bug fixes**: Always welcome
- **New tools**: Add to Brewfile with clear rationale
- **Improvements**: Better error handling, performance, etc.
- **Documentation**: Help make setup clearer

## Questions?

Open an issue for discussion before major changes.
