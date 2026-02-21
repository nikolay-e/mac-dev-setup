#!/usr/bin/env bash

# Stop on first error, undefined variables, and pipe failures
set -euo pipefail

# --- Helper Functions ---
# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions for consistent output
info() {
    printf "${BLUE}[*]${NC} %s\n" "$1"
}

warn() {
    printf "${YELLOW}[!]${NC} %s\n" "$1"
}

success() {
    printf "${GREEN}[+]${NC} %s\n" "$1"
}

error() {
    printf "${RED}[-]${NC} %s\n" "$1"
}

# Get the repository root
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

# Default flag values
YES=0

# Parse arguments
while (( "$#" )); do
    case $1 in
        --yes)
            YES=1
            ;;
        --help)
            echo "mac-dev-setup uninstaller"
            echo ""
            echo "Usage: $0 [--yes]"
            echo "  --yes        Skip interactive prompts and proceed automatically"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
    shift
done

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
  info "Removing symlinks and configuration files..."

  # Remove legacy alias symlink (backwards compatibility)
  if [ -h ~/.mac-dev-setup-aliases ]; then
    rm ~/.mac-dev-setup-aliases
    echo "Removed legacy ~/.mac-dev-setup-aliases symlink"
  fi

  # Remove zsh_config symlink
  if [ -h ~/.zsh_config.sh ]; then
    rm ~/.zsh_config.sh
    echo "Removed ~/.zsh_config.sh symlink"
  fi

  # Remove Sheldon config file and lock file (generated, not symlinked)
  if [ -f ~/.config/sheldon/plugins.toml ]; then
    rm ~/.config/sheldon/plugins.toml
    echo "Removed Sheldon config file"
  fi

  if [ -f ~/.config/sheldon/plugins.lock ]; then
    rm ~/.config/sheldon/plugins.lock
    echo "Removed Sheldon lock file"
  fi

  # Remove Sheldon downloaded plugins
  if [ -d ~/.local/share/sheldon ]; then
    rm -rf ~/.local/share/sheldon
    echo "Removed Sheldon plugin cache"
  fi

  # Remove Starship config file
  if [ -f ~/.config/starship.toml ]; then
    rm ~/.config/starship.toml
    echo "Removed Starship configuration"
  fi

  # Clean up old npm-based plugin installations (backwards compatibility)
  remove_old_npm_plugins

}

remove_old_npm_plugins() {
  info "Checking for old npm-based plugin installations..."

  local old_npm_found=0

  # Check for old node_modules directory in the project
  if [ -d "$HOME/.config/sheldon/node_modules" ]; then
    rm -rf "$HOME/.config/sheldon/node_modules"
    echo "Removed old node_modules from Sheldon config"
    old_npm_found=1
  fi

  # Check for manually installed Zsh plugins (from old npm setup)
  local old_plugin_dirs=(
    "$HOME/.config/sheldon/repos"
    "$HOME/.local/share/sheldon/repos"
    "$HOME/.cache/sheldon"
  )

  for dir in "${old_plugin_dirs[@]}"; do
    if [ -d "$dir" ]; then
      # Look for zsh plugin repositories
      find "$dir" -maxdepth 2 -type d \( -name "*zsh-autosuggestions*" -o -name "*zsh-syntax-highlighting*" -o -name "*zsh-completions*" \) -exec rm -rf {} + 2>/dev/null || true
      old_npm_found=1
    fi
  done

  # Remove any old package.json or package-lock.json that might be lying around
  if [ -f "$HOME/.config/sheldon/package.json" ]; then
    rm "$HOME/.config/sheldon/package.json"
    echo "Removed old package.json from Sheldon config"
    old_npm_found=1
  fi

  if [ -f "$HOME/.config/sheldon/package-lock.json" ]; then
    rm "$HOME/.config/sheldon/package-lock.json"
    echo "Removed old package-lock.json from Sheldon config"
    old_npm_found=1
  fi

  # Check for .npmrc in home directory that might have been created
  if [ -f "$HOME/.npmrc" ] && grep -q "mac-dev-setup\|sheldon" "$HOME/.npmrc" 2>/dev/null; then
    echo "Warning: Found .npmrc with potential mac-dev-setup configuration"
    echo "  You may want to review and clean up ~/.npmrc manually"
  fi

  if [ $old_npm_found -eq 0 ]; then
    echo "No old npm-based installations found"
  fi
}

cleanup_data_directories() {
  info "Optional cleanup of data directories..."

  local data_dirs=(
    "$HOME/.nvm"         # Legacy (remove if found)
    "$HOME/.pyenv"       # Legacy (remove if found)
    # "$HOME/.aws".      # Never remove this folder as this may contain credentials
    "$HOME/.config/sheldon"
    "$HOME/.local/share/sheldon"
    "$HOME/.cache/sheldon"
    "$HOME/.config/mise"
    "$HOME/.local/share/mise"
    "$HOME/.cache/mise"
    "$HOME/.fzf"
    "$HOME/.local/share/zoxide"
    "$HOME/.config/mac-dev-setup"
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
      if [[ "$dir" == "$HOME/.config/mac-dev-setup" ]]; then
        echo "  - $dir (includes your local customizations)"
      else
        echo "  - $dir"
      fi
    done
    echo ""
    if [[ $YES -eq 1 ]]; then
      echo "Auto-confirming data directory removal (--yes flag provided)"
      response="y"
    else
      echo -n "Remove these directories? This will delete all data including Node versions, Python versions, and your local customizations (y/N): "
      read -r response
    fi

    if [[ "$response" =~ ^[Yy]$ ]]; then
      for dir in "${found_dirs[@]}"; do
        if [[ "$dir" == "$HOME/.config/mac-dev-setup" ]]; then
          echo "Tip: Consider backing up $dir/local.sh before removal"
          if [[ $YES -eq 1 ]]; then
            echo "Auto-confirming removal of $dir (--yes flag provided)"
            confirm="y"
          else
            echo -n "Really remove $dir? (y/N): "
            read -r confirm
          fi
          if [[ "$confirm" =~ ^[Yy]$ ]]; then
            if rm -rf "$dir" 2>/dev/null; then
              echo "Removed: $dir"
            else
              echo "Failed to remove: $dir (may require sudo)"
            fi
          else
            echo "Preserved: $dir"
          fi
        else
          if rm -rf "$dir" 2>/dev/null; then
            echo "Removed: $dir"
          else
            echo "Failed to remove: $dir (may require sudo)"
          fi
        fi
      done
    else
      echo "Data directories preserved."
    fi
  else
    echo "No mac-dev-setup data directories found."
  fi
}

cleanup_shell_integrations() {
  info "Cleaning up shell integrations..."

  # Remove fzf shell integrations
  if [ -f ~/.fzf.zsh ]; then
    rm ~/.fzf.zsh
    echo "Removed fzf Zsh integration file"
  fi

  if [ -f ~/.fzf.bash ]; then
    rm ~/.fzf.bash
    echo "Removed fzf Bash integration file"
  fi

  # Remove learn-aliases script
  if [ -f "$HOME/.local/bin/learn-aliases" ]; then
    rm "$HOME/.local/bin/learn-aliases"
    echo "Removed learn-aliases script"
  fi

  # Check for pipx installations that might be from mac-dev-setup
  local pipx_packages
  if command -v pipx >/dev/null 2>&1; then
    pipx_packages=$(pipx list --short 2>/dev/null | grep -E "^pre-commit " || true)
    if [ -n "$pipx_packages" ]; then
      echo ""
      echo "Found mac-dev-setup pipx packages:"
      echo "$pipx_packages"
      if [[ $YES -eq 1 ]]; then
        echo "Auto-confirming pipx package removal (--yes flag provided)"
        response="y"
      else
        echo -n "Remove these pipx packages? (y/N): "
        read -r response
      fi
      if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "$pipx_packages" | while read -r package_line; do
          if [ -n "$package_line" ]; then
            package_name=$(echo "$package_line" | cut -d' ' -f1)
            pipx uninstall "$package_name" 2>/dev/null && echo "Removed pipx package: $package_name" || echo "Failed to remove: $package_name"
          fi
        done
      fi
    fi
  fi

  # Clean up Homebrew packages (interactive removal)
  echo ""
  warn "Homebrew packages installed by mac-dev-setup are still present."
  echo "These packages include: bat, eza, ripgrep, fd, zoxide, sheldon, mise, pipx,"
  echo "colima, docker, kubectl, helm, tenv, k9s, kubectx, terraform-docs, and others."
  echo ""

  # List currently installed packages from Brewfile
  local installed_packages=()
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*brew[[:space:]]+\"([^\"]+)\" ]]; then
      local package="${BASH_REMATCH[1]}"
      if brew list "$package" &>/dev/null; then
        installed_packages+=("$package")
      fi
    fi
  done < "$REPO_ROOT/Brewfile"

  if [ ${#installed_packages[@]} -eq 0 ]; then
    info "No mac-dev-setup packages found to remove."
  else
    echo "Currently installed packages from mac-dev-setup:"
    printf "  • %s\n" "${installed_packages[@]}"
    echo ""

    if [[ $YES -eq 1 ]]; then
      echo "Auto-confirming package removal (--yes flag provided)"
      REPLY="y"
    else
      read -p "Do you want to uninstall these packages? (y/N) " -n 1 -r
      echo
    fi
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      info "Uninstalling Homebrew packages..."
      for package in "${installed_packages[@]}"; do
        echo "Removing $package..."
        # Temporarily disable errexit for this command
        set +e
        brew uninstall "$package" 2>/dev/null
        local exit_code=$?
        set -e

        if [ $exit_code -eq 0 ]; then
          echo "[+] Removed $package"
        else
          echo "Failed to remove $package (may have dependencies)"
        fi
      done
      echo ""
      info "Package removal complete."
    else
      info "Homebrew packages left installed."
      echo "To manually remove them later, use: brew uninstall <package-name>"
    fi
  fi
  echo ""
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

if [[ $YES -eq 1 ]]; then
  echo "Auto-confirming uninstall (--yes flag provided)"
  response="y"
else
  echo -n "Continue? (y/N): "
  read -r response
fi

if [[ "$response" =~ ^[Yy]$ ]]; then
  info "Starting uninstall process..."
  remove_shell_config
  remove_symlinks
  cleanup_shell_integrations
  cleanup_data_directories
  restore_backups
  info "Uninstall complete! Restart your terminal to apply changes."
  echo ""
  echo "Additional cleanup available:"
  echo "   • To remove Homebrew packages: cd $REPO_ROOT && brew bundle cleanup"
  echo "   • To completely remove Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)\""
  echo ""
else
  echo "Uninstall cancelled."
fi
