# mac-dev-setup

> Extends [../CLAUDE.md](../CLAUDE.md)

Secure, offline-first macOS development environment automation.

## Quick Start

```bash
git clone https://github.com/nikolay-e/mac-dev-setup.git
cd mac-dev-setup
./install.sh          # Full installation
./install.sh --dry    # Preview changes
./uninstall.sh        # Remove everything
```

## What's Included

- **Modern CLI**: `eza`, `bat`, `fd`, `rg`, `zoxide`, `fzf`
- **Editors**: `neovim`, `zellij` (multiplexer)
- **Containers**: `colima` (Docker alternative), `docker`, `kubectl`, `helm`, `k9s`
- **Languages**: `mise` (polyglot version manager)
- **Cloud**: `tenv` (terraform/terragrunt), `awscli`
- **600+ aliases**: Run `learn-aliases` after install

## Security

- Zero telemetry, no auto-updates
- Offline-capable
- `colima` + `docker` CLI (no Docker Desktop)

## Structure

```
mac-dev-setup/
├── install.sh       # Main installer
├── uninstall.sh     # Removal script
├── Brewfile         # Homebrew packages
├── plugins.toml     # Zsh plugins (sheldon)
├── starship.toml    # Prompt config
└── zsh_config.sh    # Aliases and config
```

## Maintenance

```bash
brew update && brew upgrade && pipx upgrade-all
```

## Requirements

- macOS 12+ (Monterey)
- Zsh (`chsh -s /bin/zsh`)
- Xcode CLI (`xcode-select --install`)
