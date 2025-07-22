#!/usr/bin/env bash

# Stop on first error, undefined variables, and pipe failures
set -euo pipefail

# --- Helper Functions ---
source "$(dirname "$0")/tasks/common.sh"

# --- Main Functions ---
remove_shell_config() {
  info "Removing shell configuration..."

  # Define all possible markers
  CONFIG_BEGIN_MARKER="# BEGIN mac-dev-setup configuration"
  CONFIG_END_MARKER="# END mac-dev-setup configuration"
  TELEMETRY_BEGIN_MARKER="# BEGIN mac-dev-setup telemetry settings"
  TELEMETRY_END_MARKER="# END mac-dev-setup telemetry settings"

  local found_config=0
  local config_file=~/.zshrc

  # Check if any mac-dev-setup blocks exist
  if grep -q "$CONFIG_BEGIN_MARKER\|$TELEMETRY_BEGIN_MARKER" "$config_file" 2>/dev/null; then
    found_config=1

    # Create backup before modifying
    local backup_file
    backup_file="$config_file.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$config_file" "$backup_file"
    echo "Created backup: $backup_file"

    # Remove configuration block if it exists
    if grep -q "$CONFIG_BEGIN_MARKER" "$config_file" 2>/dev/null; then
      sed -i '' "/$CONFIG_BEGIN_MARKER/,/$CONFIG_END_MARKER/d" "$config_file"
      echo "  Removed configuration block"
    fi

    # Remove telemetry block if it exists
    if grep -q "$TELEMETRY_BEGIN_MARKER" "$config_file" 2>/dev/null; then
      sed -i '' "/$TELEMETRY_BEGIN_MARKER/,/$TELEMETRY_END_MARKER/d" "$config_file"
      echo "  Removed telemetry settings block"
    fi

    # Clean up any multiple consecutive empty lines, leaving at most 2
    awk 'NF {empty=0; print} !NF {if(++empty<=2) print}' "$config_file" > "$config_file.tmp" && mv "$config_file.tmp" "$config_file"

    echo "All mac-dev-setup configuration removed from ~/.zshrc"
  fi

  if [[ $found_config -eq 0 ]]; then
    echo "No mac-dev-setup configuration found in ~/.zshrc"
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

  # Remove Sheldon config file (generated, not symlinked)
  if [ -f ~/.config/sheldon/plugins.toml ]; then
    rm ~/.config/sheldon/plugins.toml
    echo "Removed Sheldon config file"
  fi

}

cleanup_data_directories() {
  info "Optional cleanup of data directories..."

  local data_dirs=(
    "$HOME/.nvm"
    "$HOME/.pyenv"
    "$HOME/.aws"
    "$HOME/.config/sheldon"
    "$HOME/.local/share/sheldon"
  )

  local found_dirs=()

  # Check which directories exist
  for dir in "${data_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
      found_dirs+=("$dir")
    fi
  done

  if [[ ${#found_dirs[@]} -gt 0 ]]; then
    echo ""
    echo "The following data directories were created by mac-dev-setup:"
    for dir in "${found_dirs[@]}"; do
      echo "  - $dir"
    done
    echo ""
    echo -n "Remove these directories? This will delete all data including Node versions, Python versions, etc. (y/N): "
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
      for dir in "${found_dirs[@]}"; do
        if rm -rf "$dir" 2>/dev/null; then
          echo "Removed: $dir"
        else
          echo "Failed to remove: $dir (may require sudo)"
        fi
      done
    else
      echo "Data directories preserved."
    fi
  else
    echo "No mac-dev-setup data directories found."
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
  cleanup_data_directories
  restore_backups
  info "OK Uninstall complete! Restart your terminal to apply changes."
  printf "\nTo remove Homebrew packages, run: brew bundle cleanup --file=./Brewfile\n"
else
  echo "Uninstall cancelled."
fi
