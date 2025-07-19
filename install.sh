#!/bin/bash

# Stop on first error, undefined variables, and pipe failures
set -euo pipefail

# --- Command Line Options ---
DRY_RUN=0
NON_INTERACTIVE=0

while getopts ":n" opt; do
  case $opt in
    n)
      DRY_RUN=1
      NON_INTERACTIVE=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done
shift $((OPTIND - 1))

# --- Helper Functions ---
run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "+ $*"
  else
    "$@"
  fi
}
info() {
  printf "\n%s\n" "$1"
}

# --- Main Logic Functions ---
setup_homebrew() {
  info "Checking Homebrew & Installing packages from Brewfile..."

  # Detect architecture and set Homebrew prefix
  BREW_PREFIX=$(uname -m | grep -q arm64 && echo /opt/homebrew || echo /usr/local)

  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing..."
    run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Only add to .zprofile if not already present
  if ! grep -q "$BREW_PREFIX/bin/brew shellenv" ~/.zprofile 2>/dev/null; then
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "+ (echo; echo \"eval \\\"\\\$($BREW_PREFIX/bin/brew shellenv)\\\"\") >> ~/.zprofile"
    else
      (
        echo
        echo "eval \"\$($BREW_PREFIX/bin/brew shellenv)\""
      ) >>~/.zprofile
    fi
  fi
  eval "$("$BREW_PREFIX"/bin/brew shellenv)"

  run brew update
  run brew bundle

  # Upgrade any outdated packages to prevent warnings
  echo "Upgrading any outdated packages..."
  run brew upgrade || echo "Warning: Some packages failed to upgrade"

  # Install fzf shell integration idempotently
  if [ -d "$BREW_PREFIX/opt/fzf" ]; then
    run "$BREW_PREFIX/opt/fzf/install" --no-update-rc --key-bindings --completion
  fi
}

setup_python() {
  info "Setting up Global Python Environment..."
  PYTHON_VERSION="${PYTHON_VERSION:-3.12}"

  # Find latest patch version for the specified major.minor
  if command -v pyenv &>/dev/null; then
    local latest_version
    latest_version=$(pyenv install --list | grep -E "^  ${PYTHON_VERSION}\.[0-9]+$" | tail -1 | xargs)
    if [[ -n "$latest_version" ]]; then
      PYTHON_VERSION="$latest_version"
      echo "Using latest Python ${PYTHON_VERSION}"
    else
      echo "Warning: Could not find Python ${PYTHON_VERSION}, using default"
      PYTHON_VERSION="3.12.4" # Fallback
    fi
  else
    echo "pyenv not available (dry-run mode), using default Python ${PYTHON_VERSION}"
    PYTHON_VERSION="3.12.4" # Fallback for dry-run
  fi

  if command -v pyenv &>/dev/null; then
    if ! pyenv versions --bare | grep -q "^$PYTHON_VERSION$"; then
      run pyenv install "$PYTHON_VERSION"
    else
      echo "Python $PYTHON_VERSION is already installed. Skipping."
    fi
    run pyenv global "$PYTHON_VERSION"
  else
    echo "pyenv not available, skipping Python installation"
  fi

  info "Installing Python CLI tools via pipx..."
  # Ensure pipx path is set up (only if not already done)
  if command -v pipx &>/dev/null; then
    if ! echo "$PATH" | grep -q "\.local/bin"; then
      run pipx ensurepath
    else
      echo "pipx path already configured"
    fi
  else
    echo "pipx not available, skipping path setup"
  fi

  local dir
  dir=$(pwd)

  # Install packages from requirements.txt
  if command -v pipx &>/dev/null; then
    while IFS= read -r package || [ -n "$package" ]; do
      # Skip empty lines and comments
      [[ -z "$package" || "$package" =~ ^[[:space:]]*# ]] && continue

      # Extract package name (handle comments on same line)
      package_line=$(echo "$package" | sed 's/[[:space:]]*#.*//' | xargs)
      [[ -z "$package_line" ]] && continue

      # Extract the actual package name for checking if installed
      if [[ "$package_line" =~ git\+ ]]; then
        # For git URLs, extract the subdirectory name or repo name
        if [[ "$package_line" =~ subdirectory=([^/]+) ]]; then
          package_name="${BASH_REMATCH[1]}"
        else
          package_name=$(echo "$package_line" | sed 's|.*/||' | sed 's|\.git.*||')
        fi
      elif [[ "$package_line" =~ ^\./(.+) ]]; then
        # For local packages, use the directory name
        package_name="${BASH_REMATCH[1]}"
        # Convert relative path to absolute
        package_line="$dir/$package_line"
      else
        package_name="$package_line"
      fi

      # Check if already installed
      if pipx list | grep -q -E "(^  |package )$package_name"; then
        # For local packages, reinstall to get updates
        if [[ "$package_line" =~ ^\./(.+) || "$package_line" =~ ^/ ]]; then
          echo "$package_name is installed but local package may have updates. Reinstalling..."
          if run pipx install --force "$package_line"; then
            echo "OK Successfully reinstalled $package_name"
          else
            echo "WARNING  Failed to reinstall $package_name"
          fi
        else
          echo "$package_name is already installed via pipx. Skipping."
        fi
      else
        echo "Installing $package_name via pipx..."
        if run pipx install "$package_line"; then
          echo "OK Successfully installed $package_name"
        else
          echo "WARNING  Failed to install $package_name"
        fi
      fi
    done <"$dir/requirements.txt"
  else
    echo "pipx not available, skipping Python package installations"
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
    run nvm install --lts
    run nvm use --lts
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

  run mkdir -p "$olddir"
  echo "Backing up existing configs to $olddir"

  for file in "${files_to_link[@]}"; do
    if [ -f "$HOME/$file" ] || [ -h "$HOME/$file" ]; then
      run mv "$HOME/$file" "$olddir/"
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
    run ln -sfn "$dir/$source_file" "$HOME/$file"
    echo "Linked ~/$file"
  done

  # Link Sheldon plugins config
  run mkdir -p "$HOME/.config/sheldon"
  if [ -f "$HOME/.config/sheldon/plugins.toml" ] || [ -h "$HOME/.config/sheldon/plugins.toml" ]; then
    run mv "$HOME/.config/sheldon/plugins.toml" "$olddir/"
  fi
  run ln -sfn "$dir/plugins.toml" "$HOME/.config/sheldon/plugins.toml"
  echo "Linked Sheldon plugins config"

}

configure_shell() {
  info "Configuring Zsh..."
  # The source path now points to the symlink in the user's home directory
  local ZSHRC_SOURCE_LINE="source ~/.zsh_config.sh"

  if ! grep -Fxq "$ZSHRC_SOURCE_LINE" ~/.zshrc; then
    echo "Adding source line to ~/.zshrc..."
    if [[ $DRY_RUN -eq 1 ]]; then
      printf "+ printf '\\n# Load mac-dev-setup configuration\\n%%s\\n' '%s' >> ~/.zshrc\\n" "$ZSHRC_SOURCE_LINE"
    else
      printf "\n# Load mac-dev-setup configuration\n%s\n" "$ZSHRC_SOURCE_LINE" >>~/.zshrc
    fi
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
  if ! command -v jq &>/dev/null; then
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
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "+ cat > '$dir/plugins.toml' << 'EOF'..."
  else
    cat >"$dir/plugins.toml" <<'EOF'
# plugins.toml
# This file is AUTO-GENERATED from package.json by install.sh
# DO NOT EDIT MANUALLY - Edit package.json instead

shell = "zsh"

[plugins]

EOF
  fi

  # Parse dependencies from package.json and generate TOML entries
  jq -r '.dependencies | to_entries[] | select(.value | startswith("git+https://github.com/")) | "\(.key) \(.value)"' "$dir/package.json" | while read -r name url; do
    # Extract GitHub repo from git URL
    github_repo=$(echo "$url" | sed 's|git+https://github.com/||' | sed 's|\.git#.*||')

    # Add to plugins.toml
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "+ cat >> '$dir/plugins.toml' << EOF..."
    else
      cat >>"$dir/plugins.toml" <<EOF
# $(echo "$name" | tr '-' ' ' | sed 's/zsh //' | sed 's/\b\w/\U&/g')
[plugins.$name]
github = "$github_repo"

EOF
    fi
  done

  echo "Generated plugins.toml from package.json dependencies"
}

configure_git() {
  info "Configuring Git to use Delta for diffs..."

  # Only configure delta if it's installed
  if command -v delta &>/dev/null; then
    run git config --global core.pager delta
    run git config --global interactive.diffFilter "delta --color-only"
    run git config --global delta.navigate true
    run git config --global delta.light false # Set to true for light terminal themes
    run git config --global delta.side-by-side true
    run git config --global merge.conflictstyle diff3
    run git config --global diff.colorMoved default
    echo "Git configured to use delta."
  else
    echo "Warning: delta not found, skipping Git delta configuration"
    echo "Git will use default pager"
  fi
}

install_krew_plugins() {
  info "Installing essential kubectl plugins via krew..."

  # Check if kubectl is available
  if ! command -v kubectl &>/dev/null; then
    echo "kubectl not found, skipping krew plugins"
    return
  fi

  # Install krew if not available
  if ! command -v krew &>/dev/null; then
    echo "Installing krew (kubectl plugin manager)..."
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "+ Installing krew (kubectl plugin manager)..."
      echo "+ curl -fsSLO https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-*.tar.gz"
      echo "+ tar zxvf krew-*.tar.gz"
      echo "+ ./krew-* install krew"
    else
      (
        set -x
        cd "$(mktemp -d)" &&
          OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
          ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
          KREW="krew-${OS}_${ARCH}" &&
          curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
          tar zxvf "${KREW}.tar.gz" &&
          ./"${KREW}" install krew
      )
    fi

    # Add krew to PATH for current session
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

    # Verify krew installation
    if ! command -v krew &>/dev/null; then
      echo "Warning: krew installation failed, skipping plugins"
      return
    fi
    echo "krew installed successfully"
  fi

  # Install essential plugins
  local plugins=("neat" "tree" "access-matrix")
  for plugin in "${plugins[@]}"; do
    if kubectl krew list 2>/dev/null | grep -q "^$plugin"; then
      echo "$plugin already installed"
    else
      echo "Installing kubectl-$plugin..."
      run kubectl krew install "$plugin" || echo "Failed to install $plugin"
    fi
  done

  echo "krew plugins installation complete"
}

validate_installation() {
  info "Validating installation..."
  local failed=0

  # Test key CLI tools
  local tools=("bat" "eza" "fd" "rg" "zoxide" "jq" "jc" "yq" "nvim" "tldr" "lazygit" "dive" "kubectx" "k9s" "stern" "kcat" "tenv" "mise" "trivy" "infracost" "terraform-docs" "learn-aliases")
  for tool in "${tools[@]}"; do
    if command -v "$tool" &>/dev/null; then
      printf "OK %s: %s\n" "$tool" "$(command -v "$tool")"
    else
      printf "ERROR %s: not found\n" "$tool"
      failed=1
    fi
  done

  # Test krew separately since it needs special PATH handling
  if command -v krew &>/dev/null || [ -f "${KREW_ROOT:-$HOME/.krew}/bin/krew" ]; then
    if command -v krew &>/dev/null; then
      printf "OK %s: %s\n" "krew" "$(command -v krew)"
    else
      printf "OK %s: %s\n" "krew" "${KREW_ROOT:-$HOME/.krew}/bin/krew"
    fi
  else
    printf "ERROR %s: not found\n" "krew"
    failed=1
  fi

  # Test symlinks
  if [ -L ~/.mac-dev-setup-aliases ] && [ -f ~/.mac-dev-setup-aliases ]; then
    echo "OK Aliases: symlinked correctly"
  else
    echo "ERROR Aliases: symlink failed"
    failed=1
  fi

  if [ -L ~/.zsh_config.sh ] && [ -f ~/.zsh_config.sh ]; then
    echo "OK Zsh config: symlinked correctly"
  else
    echo "ERROR Zsh config: symlink failed"
    failed=1
  fi

  # Test Python environment
  if command -v python &>/dev/null && python --version | grep -q "3.12"; then
    echo "OK Python: $(python --version)"
  else
    echo "ERROR Python: wrong version or not found"
    failed=1
  fi

  # Test Node.js
  if command -v node &>/dev/null; then
    echo "OK Node.js: $(node --version)"
  else
    echo "ERROR Node.js: not found"
    failed=1
  fi

  if [ $failed -eq 0 ]; then
    echo ""
    printf "DONE All components installed successfully!\n"
    return 0
  else
    echo ""
    printf "WARNING  Some components failed to install properly.\n"
    return 1
  fi
}

prompt_terminal_restart() {
  echo ""
  info "RESTART Terminal Restart Required"
  echo "To activate all new features (modern prompt, aliases, tools), you need to restart your terminal."
  echo ""
  echo "Options:"
  echo "1. Reload shell in current session (exec zsh)"
  echo "2. I'll restart terminal manually later"
  echo ""
  if [[ $NON_INTERACTIVE -eq 0 ]]; then
    printf "Choose [1/2]: "
    read -r choice
  else
    echo "Non-interactive mode - skipping prompt"
    choice="2"
  fi

  case $choice in
    1 | "")
      echo ""
      echo "... Reloading shell configuration..."
      echo "Try these new commands:"
      echo "  • eza          # Better ls"
      echo "  • bat README.md # Syntax highlighted cat"
      echo "  • z <dir>      # Smart directory jumping"
      echo "  • rg <pattern> # Super fast search"
      echo ""
      if [[ $DRY_RUN -eq 0 ]]; then
        exec zsh
      else
        echo "+ exec zsh (skipped in dry-run)"
      fi
      ;;
    2)
      echo ""
      echo "OK Setup complete! Please restart your terminal to see all changes."
      echo ""
      echo "Preview of new commands (after restart):"
      echo "  • eza          # Better ls with icons"
      echo "  • bat README.md # Syntax highlighted cat"
      echo "  • z <dir>      # Smart directory jumping"
      echo "  • rg <pattern> # Super fast search"
      ;;
    *)
      echo "Setup complete! Please restart your terminal to apply changes."
      ;;
  esac
}

# --- Pre-flight Checks ---
check_shell() {
  if [[ "$SHELL" != */zsh ]]; then
    echo "WARNING  Warning: Your default shell is not zsh ($SHELL)"
    echo "This setup is optimized for zsh. Consider running: chsh -s $(which zsh)"
    if [[ $NON_INTERACTIVE -eq 0 ]]; then
      echo -n "Continue anyway? (y/N): "
      read -r response
    else
      echo "Non-interactive mode - continuing with non-zsh shell"
      response="y"
    fi
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      echo "Setup cancelled. Please switch to zsh first."
      exit 1
    fi
  fi
}

# --- Main Execution ---
if [[ $DRY_RUN -eq 1 ]]; then
  info "... Starting robust macOS workstation setup (DRY RUN)..."
else
  info "... Starting robust macOS workstation setup..."
fi
check_shell
setup_homebrew
setup_python
setup_nodejs
configure_git
generate_plugins_config
link_dotfiles
configure_shell
install_krew_plugins

# Clean up Homebrew cache and old versions
info "Cleaning up Homebrew..."
run brew cleanup --prune=all 2>/dev/null || echo "Warning: Cleanup had some issues, continuing..."
run brew autoremove 2>/dev/null || echo "Warning: Autoremove had some issues, continuing..."

# Validate installation and activate configuration
if validate_installation; then
  echo ""
  info "ACTIVATING Configuration"
  echo "Loading new shell configuration and aliases..."

  # Source the main zsh configuration which will load everything
  if [ -f ~/.zshrc ]; then
    if [[ $DRY_RUN -eq 0 ]]; then
      # shellcheck source=/dev/null
      source ~/.zshrc
    else
      echo "+ source ~/.zshrc (skipped in dry-run)"
    fi
    echo "OK Configuration loaded successfully"
    echo ""
    echo "READY New configuration is now active!"
    echo ""
    echo "Try these new commands:"
    echo "  • code         # Navigate to ~/code directory"
    echo "  • eza          # Better ls with icons"
    echo "  • bat README.md # Syntax highlighted cat"
    echo "  • z <dir>      # Smart directory jumping"
    echo "  • rg <pattern> # Super fast search"
    echo "  • lg           # LazyGit terminal UI"
    echo ""
  else
    echo "Warning: ~/.zshrc not found, please restart terminal to activate changes"
  fi
else
  echo ""
  echo "ERROR Installation completed with issues. Please check the errors above."
  echo "You may need to run the script again or manually install missing components."
fi
