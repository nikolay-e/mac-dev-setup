#!/bin/zsh

echo "🚀 Starting complete macOS workstation setup..."

# --------------------------------------------------------------------
# Homebrew Installation
# --------------------------------------------------------------------
if test ! $(which brew); then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add Homebrew to your shell path
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "Updating Homebrew and formulae..."
brew update

# --------------------------------------------------------------------
# Core Command-Line Tools
# --------------------------------------------------------------------
echo "Installing essential CLI tools..."
brew install git
brew install gh           # GitHub CLI
brew install tree
brew install wget
brew install htop         # Process viewer
brew install jq           # JSON processor
brew install fzf          # Command-line fuzzy finder
$(brew --prefix)/opt/fzf/install # Post-install step for fzf

# --------------------------------------------------------------------
# Development Environments
# --------------------------------------------------------------------
echo "Installing development runtimes..."
brew install nvm          # Node Version Manager
brew install pyenv        # Python Version Manager
brew install go           # Go language

# --------------------------------------------------------------------
# GUI Applications (Casks)
# --------------------------------------------------------------------
echo "Installing GUI applications..."
brew install --cask visual-studio-code
brew install --cask iterm2
brew install --cask rectangle         # Window management
brew install --cask alfred            # Productivity app launcher
brew install --cask docker            # Containerization
brew install --cask google-chrome
brew install --cask slack
brew install --cask postman           # API client

# --------------------------------------------------------------------
# Fonts for a better terminal experience
# --------------------------------------------------------------------
echo "Installing developer fonts..."
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font

# --------------------------------------------------------------------
# Symlinking Configuration Files
# --------------------------------------------------------------------
dir=$(pwd)                               # This repository's directory
olddir=~/.dotfiles_backup                # Backup directory
files="zshrc aliases"

echo "\nCreating backup directory and symlinking config files..."
mkdir -p $olddir

for file in $files; do
    if [ -f ~/.$file ] || [ -h ~/.$file ]; then
        mv ~/.$file $olddir/
    fi
    echo "Creating symlink for .$file in home directory."
    ln -s $dir/$file ~/.$file
done

# --------------------------------------------------------------------
# Final Cleanup
# --------------------------------------------------------------------
brew cleanup
echo "\n✅ Workstation setup complete! Some changes may require a restart to take effect."