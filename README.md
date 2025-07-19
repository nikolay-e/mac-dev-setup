# mac-dev-setup 🚀

**Modern macOS development environment setup with 40+ CLI tools and 600+ aliases.**

Fast, safe, idempotent installation across Intel and Apple Silicon Macs.

## Quick Start

```bash
git clone https://github.com/nikolay-e/mac-dev-setup.git
cd mac-dev-setup
./install.sh
```

Restart your terminal when complete.

## What You Get

### Modern CLI Replacements
- `eza` → Better `ls` with icons and git status
- `bat` → Better `cat` with syntax highlighting
- `fd` → Better `find` that's faster
- `rg` → Better `grep` that's extremely fast
- `z` → Smart directory jumping

### Key Tools Installed
- **Git**: `git`, `git-delta`, `gh`, `lazygit`
- **Containers**: `docker`, `kubectl`, `k9s`, `helm`, `stern`
- **Cloud**: `aws`, `terraform`, `trivy`, `infracost`
- **Languages**: `pyenv`, `nvm`, `pipx`, `mise`
- **Terminal**: `zellij`, `fzf`, `neovim`, `tldr`

### Essential Aliases
```bash
# Git
gs              # git status
gc "message"    # git commit
gp              # git push
lg              # lazygit TUI

# Kubernetes
k               # kubectl
kgp             # kubectl get pods
kl              # kubectl logs
kdel            # kubectl delete

# Docker
d               # docker
dps             # docker ps
dcu             # docker compose up -d

# Terraform
tf              # terraform
tfp             # terraform plan
tfa             # terraform apply

# Utilities
serve           # HTTP server (current directory)
myip            # Show public IP
weather         # Check weather
```

## 🛠️ Complete Tool List

**Core Development**: git, git-delta, gh, neovim, lazygit
**CLI Replacements**: eza, bat, fd, ripgrep, zoxide, fzf
**Containers**: docker, dive, kubectl, kubectx, k9s, stern, helm
**Infrastructure**: terraform, tenv, terraform-docs, trivy, infracost
**Cloud**: aws, kcat, jq, jc, yq
**Languages**: pyenv, pipx, nvm, mise
**Terminal**: zellij, sheldon, tldr, tree, htop, shfmt
**Quality**: pre-commit, shellcheck, bats

## Maintenance

```bash
# Update everything
brew-update     # Update Homebrew packages
pipx upgrade-all # Update Python tools

# Uninstall (keeps tools, removes configs)
./uninstall.sh
```

## Requirements

- macOS 10.15+ (Intel or Apple Silicon)
- Xcode Command Line Tools: `xcode-select --install`
- Administrator access

---

Created by [Nikolay-E](https://github.com/nikolay-e) • [Issues](https://github.com/nikolay-e/mac-dev-setup/issues) • [Contributing](CONTRIBUTING.md)
