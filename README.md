# mac-dev-setup 🚀

**Modern macOS development environment setup with 40+ CLI tools and 600+ aliases.**

## Quick Start

```bash
git clone https://github.com/nikolay-e/mac-dev-setup.git
cd mac-dev-setup
./install.sh
```

## Installation Options

### 1. **Automated** (Recommended)
```bash
./install.sh              # Install everything
./install.sh --dry-run    # Preview what will be installed
./install.sh --only=brew  # Install only specific components
```

### 2. **Manual**
Follow the step-by-step guides in `docs/`:
1. Start with [docs/00-prereqs.md](docs/00-prereqs.md)
2. Continue through numbered docs in order

## What's Included

### Modern CLI Tools
- **Better basics**: `eza` (ls), `bat` (cat), `fd` (find), `rg` (grep)
- **Git tools**: `git-delta`, `gh`, `lazygit`
- **Container tools**: `docker`, `kubectl`, `k9s`, `helm`
- **Dev tools**: `terraform`, `aws`, `neovim`, `fzf`

### 600+ Aliases
```bash
gs          # git status
k           # kubectl
tf          # terraform
serve       # HTTP server in current directory
```

Run `learn-aliases` after installation to explore all shortcuts.

## Project Structure

```
mac-dev-setup/
├── docs/       # Step-by-step installation guides
├── config/     # Package lists (brew.txt, pipx.txt)
├── tasks/      # Individual installation scripts
└── install.sh  # Optional automation script
```

## Requirements

- macOS 10.15+
- Xcode Command Line Tools
- Administrator access

## Maintenance

```bash
brew update && brew upgrade    # Update Homebrew packages
pipx upgrade-all              # Update Python tools
```

## Uninstall

```bash
./uninstall.sh  # Remove configurations (keeps installed tools)
```

---

Created by [Nikolay-E](https://github.com/nikolay-e) • [Issues](https://github.com/nikolay-e/mac-dev-setup/issues)
