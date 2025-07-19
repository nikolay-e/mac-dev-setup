#!/bin/bash

# Stop on first error, undefined variables, and pipe failures
set -euo pipefail

# --- Helper Functions ---
info() {
  printf "\n\033[1;34m%s\033[0m\n" "$1"
}

# --- Main Logic Functions ---
setup_homebrew() {
  info "Checking Homebrew & Installing packages from Brewfile..."
  
  # Detect architecture and set Homebrew prefix
  BREW_PREFIX=$(uname -m | grep -q arm64 && echo /opt/homebrew || echo /usr/local)
  
  if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  
  # Only add to .zprofile if not already present
  if ! grep -q "$BREW_PREFIX/bin/brew shellenv" ~/.zprofile 2>/dev/null; then
    (echo; echo "eval \"\$($BREW_PREFIX/bin/brew shellenv)\"") >> ~/.zprofile
  fi
  eval "$("$BREW_PREFIX"/bin/brew shellenv)"
  
  brew update
  brew bundle --no-lock
  
  # Install fzf shell integration idempotently
  if [ -d "$BREW_PREFIX/opt/fzf" ]; then
    "$BREW_PREFIX/opt/fzf/install" --no-update-rc --key-bindings --completion
  fi
}

setup_python() {
  info "Setting up Global Python Environment..."
  PYTHON_VERSION="${PYTHON_VERSION:-3.12.4}"
  
  if ! pyenv versions --bare | grep -q "^$PYTHON_VERSION$"; then
    pyenv install "$PYTHON_VERSION"
  else
    echo "Python $PYTHON_VERSION is already installed. Skipping."
  fi
  pyenv global "$PYTHON_VERSION"
  
  info "Installing Python CLI tools via pipx..."
  pipx ensurepath
  if ! pipx list | grep -q treemapper; then
    pipx install treemapper
  else
    echo "treemapper is already installed. Skipping."
  fi
}

setup_nodejs() {
  info "Setting up Node.js via nvm..."
  
  # Use the same BREW_PREFIX from setup_homebrew
  BREW_PREFIX=$(uname -m | grep -q arm64 && echo /opt/homebrew || echo /usr/local)
  
  # Source nvm if available
  export NVM_DIR="$HOME/.nvm"
  if [ -f "$BREW_PREFIX/opt/nvm/nvm.sh" ]; then
    # shellcheck disable=SC1091
    source "$BREW_PREFIX/opt/nvm/nvm.sh"
    
    # Install latest LTS Node.js
    nvm install --lts
    nvm use --lts
    echo "Node.js LTS installed and activated"
  else
    echo "Warning: nvm not found. Install via Homebrew first."
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
    # For .mac-dev-setup-aliases, the source file has the same name
    # For .zsh_config.sh, the source file is zsh_config.sh (no dot)
    case $file in
      ".mac-dev-setup-aliases")
        local source_file="$file"
        ;;
      ".zsh_config.sh")
        local source_file="zsh_config.sh"
        ;;
      *)
        local source_file="${file#.}"
        ;;
    esac
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

generate_plugins_config() {
  info "Generating plugins.toml from package.json..."
  local dir
  dir=$(pwd)
  
  if [ ! -f "$dir/package.json" ]; then
    echo "ERROR: package.json not found. Cannot generate plugins.toml."
    echo "This is required for shell plugin management."
    exit 1
  fi
  
  # Check if jq is available for JSON parsing
  if ! command -v jq &> /dev/null; then
    echo "ERROR: jq not found and is required to parse package.json."
    echo "Please install jq: brew install jq"
    
    # Check if plugins.toml exists and is newer than package.json
    if [ -f "$dir/plugins.toml" ]; then
      if [ "$dir/plugins.toml" -nt "$dir/package.json" ]; then
        echo "Using existing plugins.toml (newer than package.json)."
        return
      else
        echo "ERROR: plugins.toml is older than package.json but jq unavailable."
        echo "Install jq or manually update plugins.toml."
        exit 1
      fi
    else
      echo "ERROR: No plugins.toml exists and cannot generate without jq."
      exit 1
    fi
  fi
  
  # Generate plugins.toml from package.json dependencies
  cat > "$dir/plugins.toml" << 'EOF'
# plugins.toml
# This file is AUTO-GENERATED from package.json by install.sh
# DO NOT EDIT MANUALLY - Edit package.json instead

[plugins]

EOF
  
  # Parse dependencies from package.json and generate TOML entries
  jq -r '.dependencies | to_entries[] | select(.value | startswith("git+https://github.com/")) | "\(.key) \(.value)"' "$dir/package.json" | while read -r name url; do
    # Extract GitHub repo from git URL
    github_repo=$(echo "$url" | sed 's|git+https://github.com/||' | sed 's|\.git#.*||')
    
    # Add to plugins.toml
    cat >> "$dir/plugins.toml" << EOF
# $(echo "$name" | tr '-' ' ' | sed 's/zsh //' | sed 's/\b\w/\U&/g')
[plugins.$name]
github = "$github_repo"

EOF
  done
  
  echo "Generated plugins.toml from package.json dependencies"
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
setup_nodejs
configure_git
generate_plugins_config
link_dotfiles
configure_shell

brew cleanup
info "✅ Workstation setup complete! Restart your terminal."