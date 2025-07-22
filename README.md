# mac-dev-setup 🚀

**Modern macOS development environment setup with 40+ CLI tools and 600+ aliases.**

## Quick Start

```bash
git clone https://github.com/nikolay-e/mac-dev-setup.git
cd mac-dev-setup
./install.sh
```

## Installation Options

**Automated**: `./install.sh` or `./install.sh --profile=local` (telemetry-free)
**Manual**: Follow guides in `docs/` starting with [00-prereqs.md](docs/00-prereqs.md)

## What's Included

### Modern CLI Tools
- **Better basics**: `eza` (ls), `bat` (cat), `fd` (find), `rg` (grep)
- **Git tools**: `git-delta`, `gh`
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
├── docs/           # Installation guides
├── config/full/    # All tools (default)
├── config/local/   # Telemetry-free subset
├── tasks/          # Installation scripts
└── install.sh      # Orchestrator
```

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
