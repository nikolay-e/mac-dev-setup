#!/bin/bash

# Stop on first error, undefined variables, and pipe failures
set -euo pipefail

# --- Helper Functions ---
info() {
  printf "\n\033[1;34m%s\033[0m\n" "$1"
}

success() {
  printf "\033[1;32m✓ %s\033[0m\n" "$1"
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


update_npm_packages() {
  info "Updating npm packages (shell plugins)..."
  if [ -f package.json ]; then
    npm install --ignore-scripts && npm update
    success "npm packages updated"
  else
    echo "No package.json found, skipping npm update"
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

update_mise_tools() {
  info "Updating mise runtime tools..."
  if command -v mise &> /dev/null; then
    mise upgrade
    success "mise tools updated"
  else
    echo "mise not found, skipping mise update"
  fi
}

check_outdated() {
  info "Checking for outdated packages..."
  printf "\nOutdated Homebrew packages:\n"
  brew outdated || echo "All packages are up to date!"
  
  printf "\nOutdated Python packages:\n"
  if command -v pipx &> /dev/null; then
    pipx list --outdated || echo "All Python tools are up to date!"
  else
    echo "pipx not installed"
  fi
}

# --- Main Execution ---
info "🔄 Mac Dev Setup Update Tool"
echo "This will update all tools installed by mac-dev-setup"

update_homebrew
update_python_tools
update_npm_packages
update_sheldon_plugins
update_mise_tools
check_outdated

info "✅ Update complete!"
printf "\nTip: Run 'brew doctor' to check for any issues\n"