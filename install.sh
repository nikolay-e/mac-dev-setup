#!/bin/zsh

echo "🚀 Starting robust macOS workstation setup..."

# --------------------------------------------------------------------
# Homebrew & Core Tool Installation
# --------------------------------------------------------------------
if test ! $(which brew); then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "Updating Homebrew and installing tools..."
brew update
brew install git gh tree wget htop jq fzf nvm pyenv
brew install --cask visual-studio-code iterm2 rectangle alfred docker google-chrome slack postman font-hack-nerd-font
$(brew --prefix)/opt/fzf/install --all

# --------------------------------------------------------------------
# Global Python Setup (via pyenv)
# --------------------------------------------------------------------
echo "Setting up a global Python environment..."
PYTHON_VERSION="3.11.4" # Or any other version you prefer
pyenv install $PYTHON_VERSION --skip-existing
pyenv global $PYTHON_VERSION

# --------------------------------------------------------------------
# Python CLI Tools (via pipx)
# --------------------------------------------------------------------
echo "Installing Python CLI tools..."
brew install pipx
pipx ensurepath
pipx install treemapper

# --------------------------------------------------------------------
# Symlink Project Alias File
# --------------------------------------------------------------------
dir=$(pwd)
olddir=~/.dotfiles_backup
alias_file="mac-dev-setup-aliases"
echo "\nCreating backup directory and symlinking alias file..."
mkdir -p $olddir
if [ -f ~/.$alias_file ] || [ -h ~/.$alias_file ]; then mv ~/.$alias_file $olddir/; fi
ln -s "$dir/.$alias_file" "$HOME/.$alias_file"

# --------------------------------------------------------------------
# Dynamically Add Configuration to ~/.zshrc
# --------------------------------------------------------------------
ZSHRC_CONFIG_BLOCK="# --- Mac Dev Setup Configuration ---"
if ! grep -q "$ZSHRC_CONFIG_BLOCK" ~/.zshrc; then
  echo "Adding mac-dev-setup configuration to ~/.zshrc..."
  cat <<'EOF' >> ~/.zshrc

# --- Mac Dev Setup Configuration ---
# This block is managed by the mac-dev-setup project.
if [ -f ~/.mac-dev-setup-aliases ]; then source ~/.mac-dev-setup-aliases; fi

# Pyenv (Python Version Manager)
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"

# FZF (Fuzzy Finder)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# --- End Mac Dev Setup Configuration ---
EOF
  echo "Configuration added."
else
  echo "Configuration block already exists in ~/.zshrc. Skipping."
fi

# --------------------------------------------------------------------
# Final Steps
# --------------------------------------------------------------------
brew cleanup
echo "\n✅ Workstation setup complete! Restart your terminal to use the new global Python."