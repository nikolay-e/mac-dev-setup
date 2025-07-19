#!/bin/zsh

# This file is sourced by ~/.zshrc and managed by mac-dev-setup.

# Environment Variables
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export NVM_DIR="$HOME/.nvm"

# Tool Initializations
if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if command -v starship 1>/dev/null 2>&1; then eval "$(starship init zsh)"; fi
if command -v sheldon 1>/dev/null 2>&1; then eval "$(sheldon source)"; fi
if command -v zoxide 1>/dev/null 2>&1; then eval "$(zoxide init zsh)"; fi

# Source Aliases
if [ -f ~/.mac-dev-setup-aliases ]; then source ~/.mac-dev-setup-aliases; fi