#!/bin/zsh

# Stop on first error, undefined variables, and pipe failures
set -euo pipefail

# --- Helper Functions ---
info() {
  echo "\n\033[1;34m$1\033[0m"
}

success() {
  echo "\033[1;32m✓ $1\033[0m"
}

# --- Update Functions ---
update_homebrew() {
  info "Updating Homebrew packages..."
  brew update
  brew upgrade
  brew cleanup
  success "Homebrew packages updated"
}

update_python_tools() {
  info "Updating Python tools..."
  if command -v pipx &> /dev/null; then
    pipx upgrade-all
    success "Python tools updated"
  else
    echo "pipx not found, skipping Python tools update"
  fi
}

update_sheldon_plugins() {
  info "Updating Zsh plugins..."
  if command -v sheldon &> /dev/null; then
    sheldon lock --update
    success "Zsh plugins updated"
  else
    echo "Sheldon not found, skipping plugin update"
  fi
}

check_outdated() {
  info "Checking for outdated packages..."
  echo "\nOutdated Homebrew packages:"
  brew outdated || echo "All packages are up to date!"
  
  echo "\nOutdated Python packages:"
  pipx list --outdated || echo "All Python tools are up to date!"
}

# --- Main Execution ---
info "🔄 Mac Dev Setup Update Tool"
echo "This will update all tools installed by mac-dev-setup"

update_homebrew
update_python_tools
update_sheldon_plugins
check_outdated

info "✅ Update complete!"
echo "\nTip: Run 'brew doctor' to check for any issues"