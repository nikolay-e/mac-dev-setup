#!/bin/bash

# Stop on first error, undefined variables, and pipe failures
set -euo pipefail

# --- Helper Functions ---
source "$(dirname "$0")/tasks/common.sh"

# --- Main Functions ---
remove_shell_config() {
  info "Removing shell configuration..."
  local ZSHRC_SOURCE_LINE="source ~/.zsh_config.sh"
  local ZSHRC_COMMENT="# Load mac-dev-setup configuration"

  if grep -q "$ZSHRC_SOURCE_LINE" ~/.zshrc; then
    # Create backup before modifying
    cp ~/.zshrc ~/.zshrc.backup."$(date +%Y%m%d_%H%M%S)"

    # Remove the source line and comment (portable sed)
    if sed --version >/dev/null 2>&1; then
      # GNU sed (Linux)
      sed -i "/$ZSHRC_COMMENT/d" ~/.zshrc
      sed -i "/source ~\/.zsh_config.sh/d" ~/.zshrc
    else
      # BSD sed (macOS)
      sed -i '' "/$ZSHRC_COMMENT/d" ~/.zshrc
      sed -i '' "/source ~\/.zsh_config.sh/d" ~/.zshrc
    fi
    echo "Configuration removed from ~/.zshrc (backup created)"
  else
    echo "No configuration found in ~/.zshrc"
  fi
}

remove_symlinks() {
  info "Removing symlinks..."

  # Remove alias symlink
  if [ -h ~/.mac-dev-setup-aliases ]; then
    rm ~/.mac-dev-setup-aliases
    echo "Removed ~/.mac-dev-setup-aliases symlink"
  fi

  # Remove zsh_config symlink
  if [ -h ~/.zsh_config.sh ]; then
    rm ~/.zsh_config.sh
    echo "Removed ~/.zsh_config.sh symlink"
  fi

  # Remove Sheldon config symlink
  if [ -h ~/.config/sheldon/plugins.toml ]; then
    rm ~/.config/sheldon/plugins.toml
    echo "Removed Sheldon config symlink"
  fi

}

restore_backups() {
  info "Checking for backups to restore..."
  local backup_dir=~/.dotfiles_backup

  if [ -d "$backup_dir" ]; then
    echo "Found backup directory: $backup_dir"
    echo "You can manually restore files from this directory if needed."
  else
    echo "No backup directory found."
  fi
}

# --- Main Execution ---
warn "This will remove mac-dev-setup configuration from your system."
echo "Your installed tools (via Homebrew) will NOT be removed."
echo -n "Continue? (y/N): "
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
  info "Starting uninstall process..."
  remove_shell_config
  remove_symlinks
  restore_backups
  info "OK Uninstall complete! Restart your terminal to apply changes."
  printf "\nTo remove Homebrew packages, run: brew bundle cleanup --file=./Brewfile\n"
else
  echo "Uninstall cancelled."
fi
