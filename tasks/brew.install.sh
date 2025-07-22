#!/usr/bin/env bash
# tasks/brew.install.sh - install packages listed in Brewfile
#
# Usage:
#   bash tasks/brew.install.sh           # Install all packages
#   bash tasks/brew.install.sh --dry-run # Show what would be installed
#   bash tasks/brew.install.sh --print   # Print raw commands for copy-paste

set -euo pipefail

# Environment variables for current session only
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

# Load common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Parse arguments
parse_common_args "Install Homebrew packages from Brewfile" "$@"

# Find config file relative to script location
CONFIG_FILE="$SCRIPT_DIR/../Brewfile"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Config file not found: $CONFIG_FILE"
  exit 1
fi

# Check if Homebrew is installed (skip for dry-run and print modes)
if ! command -v brew &>/dev/null && [[ $PRINT -eq 0 && $DRY -eq 0 ]]; then
  echo "Error: Homebrew is not installed. See docs/10-homebrew.md"
  exit 1
fi

# Use brew bundle for robust installation
if (( PRINT )); then
  echo "brew bundle --file=\"$CONFIG_FILE\""
elif (( DRY )); then
  run_cmd "brew bundle --file=\"$CONFIG_FILE\" --dry-run"
else
  run_cmd "brew bundle --file=\"$CONFIG_FILE\""
  echo "Homebrew packages installation complete!"
fi
