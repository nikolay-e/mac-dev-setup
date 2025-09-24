# shellcheck shell=bash
# zsh_config.sh
# This file is sourced by ~/.zshrc and managed by mac-dev-setup.

# Environment Variables
export PATH="$HOME/.local/bin:$PATH" # pipx tools

# Tool Initializations
# shellcheck disable=SC1090
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Initialize Starship prompt
if command -v starship 1>/dev/null 2>&1; then eval "$(starship init zsh)"; fi
if command -v sheldon 1>/dev/null 2>&1; then eval "$(sheldon source)"; fi
if command -v zoxide 1>/dev/null 2>&1; then eval "$(zoxide init zsh)"; fi
if command -v mise 1>/dev/null 2>&1; then eval "$(mise activate zsh)"; fi

# Source Modular Aliases
# shellcheck disable=SC1090
if [ -d ~/.config/mac-dev-setup/modules ]; then
  for module_file in ~/.config/mac-dev-setup/modules/*.sh; do
    [ -r "$module_file" ] && source "$module_file"
  done
fi

# Source Local Customizations (loaded last to override defaults)
# shellcheck disable=SC1090
if [ -f ~/.config/mac-dev-setup/local.sh ]; then
  source ~/.config/mac-dev-setup/local.sh
fi

# Personal overrides (legacy support)
# shellcheck disable=SC1090
if [ -f ~/.my_aliases ]; then source ~/.my_aliases; fi
