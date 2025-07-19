#!/bin/zsh

# Stop on first error, undefined variables, and pipe failures
set -euo pipefail

# --- Helper Functions ---
info() {
  echo "\n\033[1;34m$1\033[0m"
}

# --- Main Logic Functions ---
setup_homebrew() {
  info "Checking Homebrew & Installing packages from Brewfile..."
  if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Only add to .zprofile if not already present
  if ! grep -q '/opt/homebrew/bin/brew shellenv' ~/.zprofile 2>/dev/null; then
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"
  
  brew update
  brew bundle --no-lock
  $(brew --prefix)/opt/fzf/install --all
}

setup_python() {
  info "Setting up Global Python Environment..."
  PYTHON_VERSION="3.12.4"
  
  if ! pyenv versions --bare | grep -q "^$PYTHON_VERSION$"; then
    pyenv install $PYTHON_VERSION
  else
    echo "Python $PYTHON_VERSION is already installed. Skipping."
  fi
  pyenv global $PYTHON_VERSION
  
  info "Installing Python CLI tools via pipx..."
  pipx ensurepath
  if ! pipx list | grep -q treemapper; then
    pipx install treemapper
  else
    echo "treemapper is already installed. Skipping."
  fi
}

link_dotfiles() {
  info "Linking dotfiles..."
  local dir=$(pwd)
  local olddir=~/.dotfiles_backup
  local alias_file="mac-dev-setup-aliases"
  
  mkdir -p "$olddir"
  if [ -f "$HOME/.$alias_file" ] || [ -h "$HOME/.$alias_file" ]; then
    mv "$HOME/.$alias_file" "$olddir/"
  fi
  ln -sfn "$dir/.$alias_file" "$HOME/.$alias_file"
  
  # Link Sheldon plugins config
  mkdir -p "$HOME/.config/sheldon"
  if [ -f "$HOME/.config/sheldon/plugins.toml" ] || [ -h "$HOME/.config/sheldon/plugins.toml" ]; then
    mv "$HOME/.config/sheldon/plugins.toml" "$olddir/"
  fi
  ln -sfn "$dir/plugins.toml" "$HOME/.config/sheldon/plugins.toml"
}

configure_shell() {
  info "Configuring Zsh..."
  local ZSHRC_SOURCE_LINE="source ~/mac-dev-setup/zsh_config.sh"
  
  if ! grep -q "$ZSHRC_SOURCE_LINE" ~/.zshrc; then
    echo "Adding source line to ~/.zshrc..."
    echo "\n# Load mac-dev-setup configuration" >> ~/.zshrc
    echo "$ZSHRC_SOURCE_LINE" >> ~/.zshrc
  else
    echo "Source line already exists in ~/.zshrc. Skipping."
  fi
}

# --- Main Execution ---
info "🚀 Starting robust macOS workstation setup..."
setup_homebrew
setup_python
link_dotfiles
configure_shell

brew cleanup
info "✅ Workstation setup complete! Restart your terminal."