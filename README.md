# mac-dev-setup 🚀

**Secure, offline-first macOS development environment with vetted tools and no telemetry.**

## Quick Start

```bash
git clone https://github.com/nikolay-e/mac-dev-setup.git
cd mac-dev-setup
./install.sh
```

## What's Included

All tools are carefully vetted for security and work completely offline:

### Core Development Tools
- **Git ecosystem**: `git`, modern diffs, terminal workflows
- **Modern CLI**: `eza` (ls), `bat` (cat), `fd` (find), `rg` (grep), `zoxide` (cd)
- **Editors & Terminal**: `neovim`, `zellij` multiplexer
- **Language environments**: `pyenv`, `nvm`, `mise`

### Infrastructure & Containers
- **Container tools**: `docker`, `kubectl`, `helm`
- **Infrastructure**: `terraform`, `terragrunt`
- **Utilities**: `jq`, `jc`, `tree`, `fzf`, `wget`, `htop`

### 600+ Productivity Aliases
```bash
gs          # git status
k           # kubectl
tf          # terraform
serve       # HTTP server in current directory
```

Run `learn-aliases` after installation to explore all shortcuts.

## Security Features

🔒 **Zero Telemetry**: No analytics, crash reporting, or usage tracking
🔒 **No Auto-Updates**: Tools won't check for updates or phone home
🔒 **Offline Capable**: All tools work without internet connection
🔒 **User-Controlled Network**: Only you decide when tools connect externally

## Manual Installation

For step-by-step setup, see `docs/10-homebrew.md`.

## Requirements

- macOS 10.15+
- Xcode Command Line Tools
- Administrator access

## Maintenance

```bash
brew update && brew upgrade && pipx upgrade-all
```

---

Created by [Nikolay-E](https://github.com/nikolay-e) • [Issues](https://github.com/nikolay-e/mac-dev-setup/issues)
