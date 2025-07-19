#!/bin/zsh

# Stop on first error, undefined variables, and pipe failures
set -euo pipefail

# --- Helper Functions ---
info() {
  printf "\n\033[1;34m%s\033[0m\n" "$1"
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
    (echo; echo "eval \"\$(/opt/homebrew/bin/brew shellenv)\"") >> ~/.zprofile
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"
  
  brew update
  brew bundle --no-lock
  "$(brew --prefix)/opt/fzf/install" --all
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
  local dir
  dir=$(pwd)
  local olddir="$HOME/.dotfiles_backup"
  local files_to_link=(".mac-dev-setup-aliases" ".zsh_config.sh")

  mkdir -p "$olddir"
  echo "Backing up existing configs to $olddir"

  for file in "${files_to_link[@]}"; do
    if [ -f "$HOME/$file" ] || [ -h "$HOME/$file" ]; then
      mv "$HOME/$file" "$olddir/"
    fi
    # Remove leading dot from source file name
    local source_file="${file#.}"
    ln -sfn "$dir/$source_file" "$HOME/$file"
    echo "Linked ~/$file"
  done

  # Link Sheldon plugins config
  mkdir -p "$HOME/.config/sheldon"
  if [ -f "$HOME/.config/sheldon/plugins.toml" ] || [ -h "$HOME/.config/sheldon/plugins.toml" ]; then
    mv "$HOME/.config/sheldon/plugins.toml" "$olddir/"
  fi
  ln -sfn "$dir/plugins.toml" "$HOME/.config/sheldon/plugins.toml"
  echo "Linked Sheldon plugins config"
}

configure_shell() {
  info "Configuring Zsh..."
  # The source path now points to the symlink in the user's home directory
  local ZSHRC_SOURCE_LINE="source ~/.zsh_config.sh"

  if ! grep -Fxq "$ZSHRC_SOURCE_LINE" ~/.zshrc; then
    echo "Adding source line to ~/.zshrc..."
    echo -e "\n# Load mac-dev-setup configuration\n$ZSHRC_SOURCE_LINE" >> ~/.zshrc
  else
    echo "Source line already exists in ~/.zshrc. Skipping."
  fi
}

configure_git() {
  info "Configuring Git to use Delta for diffs..."
  git config --global core.pager delta
  git config --global interactive.diffFilter "delta --color-only"
  git config --global delta.navigate true
  git config --global delta.light false # Set to true for light terminal themes
  git config --global delta.side-by-side true
  git config --global merge.conflictstyle diff3
  git config --global diff.colorMoved default
  echo "Git configured to use delta."
}

# --- Main Execution ---
info "🚀 Starting robust macOS workstation setup..."
setup_homebrew
setup_python
configure_git
link_dotfiles
configure_shell

brew cleanup
info "✅ Workstation setup complete! Restart your terminal."