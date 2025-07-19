#!/bin/zsh

echo "🚀 Starting robust macOS workstation setup..."

# --------------------------------------------------------------------
# Homebrew & Tool Installation (Idempotent)
# --------------------------------------------------------------------
if test ! $(which brew); then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add Homebrew to your shell path if not already configured
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "Updating Homebrew and installing tools..."
brew update
brew install git gh tree wget htop jq fzf nvm pyenv go
brew install --cask visual-studio-code iterm2 rectangle alfred docker google-chrome slack postman font-hack-nerd-font
$(brew --prefix)/opt/fzf/install --all # Post-install for fzf, --all avoids prompts

# --------------------------------------------------------------------
# Symlink the Project-Specific Alias File
# --------------------------------------------------------------------
dir=$(pwd)
olddir=~/.dotfiles_backup
alias_file="mac-dev-setup-aliases"

echo "\nCreating backup directory..."
mkdir -p $olddir

echo "Symlinking project alias file..."
# If an old alias file exists, back it up before creating the new symlink
if [ -f ~/.$alias_file ] || [ -h ~/.$alias_file ]; then
    mv ~/.$alias_file $olddir/
fi
ln -s "$dir/.$alias_file" "$HOME/.$alias_file"

# --------------------------------------------------------------------
# Dynamically Add Configuration to ~/.zshrc
# --------------------------------------------------------------------
ZSHRC_CONFIG_BLOCK="# --- Mac Dev Setup Configuration ---"

# Check if our configuration block already exists in ~/.zshrc
if ! grep -q "$ZSHRC_CONFIG_BLOCK" ~/.zshrc; then
  echo "Adding mac-dev-setup configuration to ~/.zshrc..."
  # Append the entire configuration block to ~/.zshrc
  cat <<'EOF' >> ~/.zshrc

# --- Mac Dev Setup Configuration ---
# This block is managed by the mac-dev-setup project.

# Source project-specific aliases
if [ -f ~/.mac-dev-setup-aliases ]; then
    source ~/.mac-dev-setup-aliases
fi

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"

# Pyenv (Python Version Manager)
if command -v pyenv 1>/dev/null 2>&1; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

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
echo "\n✅ Robust setup complete! Restart your terminal to apply changes."