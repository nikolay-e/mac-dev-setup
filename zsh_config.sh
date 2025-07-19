# shellcheck shell=bash
# zsh_config.sh
# This file is sourced by ~/.zshrc and managed by mac-dev-setup.

# Environment Variables
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH" # pipx tools
export NVM_DIR="$HOME/.nvm"

# Tool Initializations
if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi
# shellcheck disable=SC1091
BREW_PREFIX=$(uname -m | grep -q arm64 && echo /opt/homebrew || echo /usr/local)
# shellcheck disable=SC1091
[ -s "$BREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$BREW_PREFIX/opt/nvm/nvm.sh"
# shellcheck disable=SC1090
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Simple prompt
export PS1='%1~ %# '
if command -v sheldon 1>/dev/null 2>&1; then eval "$(sheldon source)"; fi
if command -v zoxide 1>/dev/null 2>&1; then eval "$(zoxide init zsh)"; fi
if command -v mise 1>/dev/null 2>&1; then eval "$(mise activate zsh)"; fi

# Source Aliases
# shellcheck disable=SC1090
if [ -f ~/.mac-dev-setup-aliases ]; then source ~/.mac-dev-setup-aliases; fi

# Source Personal Overrides (loaded last to override defaults)
# shellcheck disable=SC1090
if [ -f ~/.my_aliases ]; then source ~/.my_aliases; fi
