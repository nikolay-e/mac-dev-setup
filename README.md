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
- **Language environments**: `mise` (polyglot version manager)

### Infrastructure & Containers
- **Container tools**: `colima` (Docker alternative), `docker` (CLI), `kubectl`, `helm`, `k9s`
- **Cloud & Infrastructure**: `tenv` (terraform/terragrunt), `awscli`
- **Utilities**: `jq`, `jc`, `tree`, `fzf`, `wget`, `htop`, `kcat`

### Optional kubectl plugins
```bash
brew install krew
kubectl krew install tree neat access-matrix
```

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
🔒 **User-Controlled Network**: Network-capable tools (docker, kubectl, awscli) only connect when you explicitly use them

**Note**: We use `colima` + `docker` CLI for zero-telemetry container usage. No Docker Desktop required!

**Colima Note**: If Colima freezes or becomes unresponsive, restart it with `colima restart`. This is a known upstream issue that's being worked on.

## Manual Installation

For step-by-step setup, see `docs/10-homebrew.md`.

## Requirements

- macOS 12+ (Monterey or newer)
- Zsh as default shell (run `chsh -s /bin/zsh` if needed)
- Xcode Command Line Tools (run `xcode-select --install`)
- Administrator access

## Maintenance

```bash
brew update && brew upgrade && pipx upgrade-all
```

---

Created by [Nikolay-E](https://github.com/nikolay-e) • [Issues](https://github.com/nikolay-e/mac-dev-setup/issues)
