#!/bin/zsh

echo "🚀 Starting macOS workstation setup..."

# --- Install Homebrew and essential packages ---
if test ! $(which brew); then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Updating Homebrew and installing packages..."
brew update
brew install neovim tree git wget

# --- Symlinking Configuration Files ---
dir=$(pwd)                               # This repository's directory
olddir=~/.dotfiles_backup                # Backup directory for old configs
# List of files to symlink from the repo to the home directory
# This is the key change: we now manage both files.
files="zshrc aliases"

echo "\nCreating backup directory at $olddir..."
mkdir -p $olddir

echo "\nMoving existing dotfiles from ~ to backup directory and creating symlinks..."
for file in $files; do
    # If a file or symlink exists in the home directory, move it to the backup folder
    if [ -f ~/.$file ] || [ -h ~/.$file ]; then
        echo "Backing up ~/.$file to $olddir/"
        mv ~/.$file $olddir/
    fi

    # Create the new symlink from the repo to the home directory
    echo "Creating symlink for .$file in home directory."
    ln -s $dir/$file ~/.$file
done

echo "\n✅ Setup complete! Restart your terminal to apply changes."