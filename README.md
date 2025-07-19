# mac-dev-setup 🚀

A robust, productivity-focused configuration for macOS development workstations. This project automates the installation of modern CLI tools and safely integrates with your existing shell setup.

## Features

- **Modern CLI Tools**: Replaces traditional commands with faster alternatives (eza, bat, ripgrep, fd)
- **Smart Navigation**: Includes zoxide for intelligent directory jumping
- **Enhanced Terminal**: Starship prompt, syntax highlighting, and auto-suggestions
- **Python & Node Management**: Pre-configured pyenv and nvm
- **Idempotent**: Safe to run multiple times without breaking your configuration
- **Backup System**: Automatically backs up existing configurations

## Quick Start

```bash
git clone https://github.com/nikolay-e/mac-dev-setup.git
cd mac-dev-setup
./install.sh
```

## What's Included

### CLI Tools
- **Navigation**: `eza` (better ls), `zoxide` (smart cd), `fd` (better find)
- **Text Processing**: `bat` (better cat), `ripgrep` (better grep), `neovim`
- **Development**: `git`, `gh`, `fzf`, `jq`, `htop`, `tree`
- **Terminal**: `starship` prompt, `zellij` multiplexer, `sheldon` plugin manager
- **Documentation**: `tldr` (simplified man pages)

### Shell Enhancements
- **Auto-suggestions**: Based on your command history
- **Syntax Highlighting**: Real-time command validation
- **Smart Aliases**: Productivity shortcuts for common tasks

## Key Aliases

```bash
# Modern replacements
ls    → eza --icons
cat   → bat --paging=never
find  → fd
grep  → rg

# Navigation
z     → zoxide (smart directory jumping)
..    → cd ..
...   → cd ../..

# Git shortcuts
gs    → git status -s
ga    → git add
gc    → git commit -m
gp    → git push
glog  → git log --oneline --decorate --graph --all

# Utilities
update → ~/mac-dev-setup/update.sh (comprehensive: brew, pipx, sheldon)
serve  → python3 -m http.server
zj     → zellij (terminal multiplexer)
killport → killport 3000 (kill process on specific port)
```

## Maintenance

### Update All Tools
To update Homebrew, Python packages, and Zsh plugins all at once, simply run the provided update script:
```bash
update
```

This is an alias for `~/mac-dev-setup/update.sh`.

### Uninstall
```bash
./uninstall.sh
```

This removes all configurations but keeps installed tools. To remove tools:
```bash
brew bundle cleanup --file=./Brewfile
```

## Troubleshooting

### Command Not Found
After installation, restart your terminal or run:
```bash
source ~/.zshrc
```

### Slow Terminal Startup
If terminal startup is slow, you can disable specific features:
- Comment out `sheldon source` line in ~/.zshrc to disable plugins
- Comment out `starship init` line to use default prompt

### Python Issues
If pyenv Python isn't working:
```bash
pyenv rehash
pyenv global 3.12.4
```

### Homebrew Issues
If Homebrew isn't found:
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## Customization

### Add Your Own Aliases
Edit `.mac-dev-setup-aliases` and add your shortcuts.

### Change Shell Plugins
Edit `plugins.toml` to add/remove Zsh plugins managed by Sheldon.

### Update Python Version
Edit `PYTHON_VERSION` in `install.sh` before running.

### Git Delta Configuration
Git is automatically configured to use Delta for beautiful, syntax-highlighted diffs. If you prefer light terminal themes, run:
```bash
git config --global delta.light true
```

---
Created by [Nikolay-E](https://github.com/nikolay-e)