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
parse_common_args "$@" "Install Homebrew packages from Brewfile"

# Find config file relative to script location
CONFIG_FILE="$SCRIPT_DIR/../Brewfile"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Config file not found: $CONFIG_FILE"
  exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &>/dev/null && [[ $PRINT -eq 0 ]]; then
  echo "Error: Homebrew is not installed. See docs/10-homebrew.md"
  exit 1
fi

# Process each line in the Brewfile
while IFS= read -r line || [[ -n "$line" ]]; do
  # Skip empty lines and comments
  [[ -z "$line" || "$line" == \#* ]] && continue

  # Extract package name from brew "package" format
  if [[ "$line" =~ ^[[:space:]]*brew[[:space:]]+\"([^\"]+)\" ]]; then
    formula="${BASH_REMATCH[1]}"
  else
    # Skip non-brew lines
    continue
  fi

  # Build command
  cmd="brew install $formula"

  # Use common run_cmd function with continue_on_error=true
  run_cmd "$cmd" true
done < "$CONFIG_FILE"

if [[ $PRINT -eq 0 ]] && [[ $DRY -eq 0 ]]; then
  echo "Homebrew packages installation complete!"
fi
