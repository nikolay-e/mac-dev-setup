#!/usr/bin/env bash
# tasks/python.install.sh - setup Python environment with pyenv and pipx packages
#
# Usage:
#   bash tasks/python.install.sh           # Install Python and packages
#   bash tasks/python.install.sh --dry-run # Show what would be installed
#   bash tasks/python.install.sh --print   # Print raw commands for copy-paste

set -euo pipefail

# Parse arguments
DRY=0
PRINT=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) DRY=1 ;;
    --print) PRINT=1 ;;
    -h|--help)
      echo "Setup Python environment with pyenv and install pipx packages"
      echo "Usage: $0 [--dry-run] [--print]"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

# Helper function for command execution
run_cmd() {
  local cmd="$1"
  if (( PRINT )); then
    echo "$cmd"
  elif (( DRY )); then
    echo "+ $cmd"
  else
    echo "Running: $cmd"
    eval "$cmd"
  fi
}

# Find config file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/pipx.txt"

# Default Python version
PYTHON_VERSION="${PYTHON_VERSION:-3.12}"

# Step 1: Setup pyenv and install Python
if (( PRINT )); then
  echo "# Setup pyenv"
  echo "export PYENV_ROOT=\"\$HOME/.pyenv\""
  echo "export PATH=\"\$PYENV_ROOT/bin:\$PATH\""
  echo "eval \"\$(pyenv init -)\""
  echo ""
  echo "# Find latest Python $PYTHON_VERSION"
  echo "LATEST_PYTHON=\$(pyenv install --list | grep -E \"^  ${PYTHON_VERSION}\\.[0-9]+\$\" | tail -1 | xargs)"
  echo "pyenv install \"\$LATEST_PYTHON\""
  echo "pyenv global \"\$LATEST_PYTHON\""
elif [[ $DRY -eq 0 ]] && command -v pyenv &>/dev/null; then
  # Initialize pyenv
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"

  # Find latest patch version
  LATEST_VERSION=$(pyenv install --list | grep -E "^  ${PYTHON_VERSION}\.[0-9]+$" | tail -1 | xargs || echo "${PYTHON_VERSION}.0")

  if ! pyenv versions --bare | grep -q "^$LATEST_VERSION$"; then
    run_cmd "pyenv install $LATEST_VERSION"
  else
    echo "Python $LATEST_VERSION already installed"
  fi

  run_cmd "pyenv global $LATEST_VERSION"
fi

# Step 2: Ensure pipx is in PATH
if (( PRINT )); then
  echo ""
  echo "# Add pipx to PATH"
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
else
  export PATH="$HOME/.local/bin:$PATH"
fi

# Step 3: Install pipx packages
if [[ -f "$CONFIG_FILE" ]]; then
  if (( PRINT )); then
    echo ""
    echo "# Install pipx packages"
  fi

  while IFS= read -r package || [[ -n "$package" ]]; do
    # Skip empty lines and comments
    [[ -z "$package" || "$package" == \#* ]] && continue

    # Trim whitespace
    package="${package#"${package%%[![:space:]]*}"}"
    package="${package%"${package##*[![:space:]]}"}"

    if [[ "$package" == "./"* ]]; then
      # Local package - need full path
      local_path="$SCRIPT_DIR/../${package#./}"
      run_cmd "pipx install $local_path"
    else
      # Regular package
      run_cmd "pipx install $package"
    fi
  done < "$CONFIG_FILE"
fi

# Step 4: Setup shell integration
if (( PRINT )); then
  echo ""
  echo "# Add to ~/.zshrc or ~/.bash_profile:"
  echo "export PYENV_ROOT=\"\$HOME/.pyenv\""
  echo "export PATH=\"\$PYENV_ROOT/bin:\$PATH\""
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo "eval \"\$(pyenv init -)\""
elif [[ $DRY -eq 0 ]]; then
  echo ""
  echo "Python environment setup complete!"
  echo "Add these lines to your shell config if not already present:"
  echo '  export PYENV_ROOT="$HOME/.pyenv"'
  echo '  export PATH="$PYENV_ROOT/bin:$PATH"'
  echo '  export PATH="$HOME/.local/bin:$PATH"'
  echo '  eval "$(pyenv init -)"'
fi
