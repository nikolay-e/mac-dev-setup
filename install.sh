#!/bin/zsh

# Stop on first error
set -e

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
  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
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
  pipx install treemapper
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
  ln -s "$dir/.$alias_file" "$HOME/.$alias_file"
  
  # Link Sheldon plugins config
  mkdir -p "$HOME/.config/sheldon"
  if [ -f "$HOME/.config/sheldon/plugins.toml" ] || [ -h "$HOME/.config/sheldon/plugins.toml" ]; then
    mv "$HOME/.config/sheldon/plugins.toml" "$olddir/"
  fi
  ln -s "$dir/plugins.toml" "$HOME/.config/sheldon/plugins.toml"
}

configure_shell() {
  info "Configuring Zsh..."
  local ZSHRC_CONFIG_BLOCK="# --- Mac Dev Setup Configuration ---"
  
  if ! grep -q "$ZSHRC_CONFIG_BLOCK" ~/.zshrc; then
    echo "Adding configuration block to ~/.zshrc..."
    cat <<'EOF' >> ~/.zshrc

# --- Mac Dev Setup Configuration ---
# This block is managed by the mac-dev-setup project.
if [ -f ~/.mac-dev-setup-aliases ]; then source ~/.mac-dev-setup-aliases; fi
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if command -v starship 1>/dev/null 2>&1; then eval "$(starship init zsh)"; fi
if command -v sheldon 1>/dev/null 2>&1; then eval "$(sheldon source)"; fi
# --- End Mac Dev Setup Configuration ---
EOF
  else
    echo "Configuration block already exists. Skipping."
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