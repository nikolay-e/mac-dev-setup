#!/usr/bin/env bash
# tasks/python.install.sh - setup Python environment with pyenv and pipx packages
#
# Usage:
#   bash tasks/python.install.sh           # Install Python and packages
#   bash tasks/python.install.sh --dry-run # Show what would be installed
#   bash tasks/python.install.sh --print   # Print raw commands for copy-paste

set -euo pipefail

# Load common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Parse arguments
parse_common_args "Setup Python environment with pyenv and install pipx packages" "$@"

# Find config file
CONFIG_FILE="$SCRIPT_DIR/../pipx.txt"

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
elif (( DRY )); then
  echo "+ pyenv install $PYTHON_VERSION.x (latest patch version)"
  echo "+ pyenv global $PYTHON_VERSION.x"
elif [[ $DRY -eq 0 ]]; then
  # Check if pyenv is available
  if ! command -v pyenv &>/dev/null; then
    echo "Warning: pyenv not found. Install it first with 'brew install pyenv'"
    return 0
  fi
  # Initialize pyenv
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"

  # Try to install latest patch version - let pyenv handle version resolution
  echo "Installing/updating Python ${PYTHON_VERSION}..."

  # First, try the simple approach - let pyenv resolve the latest patch version
  if pyenv install "${PYTHON_VERSION}" --skip-existing 2>/dev/null; then
    # Get the actual installed version
    INSTALLED_VERSION=$(pyenv versions --bare | grep -E "^${PYTHON_VERSION}\.[0-9]+$" | tail -1)
    if [[ -n "$INSTALLED_VERSION" ]]; then
      echo "✅ Using Python $INSTALLED_VERSION"
      LATEST_VERSION="$INSTALLED_VERSION"
    else
      echo "⚠️  Warning: Could not determine installed Python version, using ${PYTHON_VERSION}.0"
      LATEST_VERSION="${PYTHON_VERSION}.0"
    fi
  else
    # Fallback to manual version parsing if pyenv doesn't support simple version format
    echo "Falling back to manual version detection..."
    LATEST_VERSION=$(pyenv install --list 2>/dev/null | grep -E "^[[:space:]]*${PYTHON_VERSION}\.[0-9]+$" | tail -1 | tr -d '[:space:]' || echo "${PYTHON_VERSION}.0")

    if ! pyenv versions --bare | grep -q "^$LATEST_VERSION$"; then
      echo "Installing Python $LATEST_VERSION..."
      if ! pyenv install "$LATEST_VERSION"; then
        echo "❌ Error: Python installation failed. This may be due to missing Xcode Command Line Tools."
        echo "Please run: xcode-select --install"
        echo "Then re-run this script."
        exit 1
      fi
    else
      echo "Python $LATEST_VERSION already installed"
    fi
  fi

  if ! pyenv global "$LATEST_VERSION"; then
    echo "❌ Error: Failed to set Python $LATEST_VERSION as global version"
    exit 1
  fi
fi

# Step 2: Ensure pipx is in PATH
if (( PRINT )); then
  echo ""
  echo "# Add pipx to PATH"
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
elif (( DRY )); then
  echo "+ export PATH=\"\$HOME/.local/bin:\$PATH\""
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
