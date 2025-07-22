#!/usr/bin/env bash
# tasks/brew.install.sh - install packages listed in config/brew.txt
#
# Usage:
#   bash tasks/brew.install.sh           # Install all packages
#   bash tasks/brew.install.sh --dry-run # Show what would be installed
#   bash tasks/brew.install.sh --print   # Print raw commands for copy-paste

set -euo pipefail

# Parse arguments
DRY=0
PRINT=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) DRY=1 ;;
    --print) PRINT=1 ;;
    -h|--help)
      echo "Install Homebrew packages from config/brew.txt"
      echo "Usage: $0 [--dry-run] [--print]"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

# Find config file relative to script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/brew.txt"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Config file not found: $CONFIG_FILE"
  exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &>/dev/null && [[ $PRINT -eq 0 ]]; then
  echo "Error: Homebrew is not installed. See docs/10-homebrew.md"
  exit 1
fi

# Process each line in the config file
while IFS= read -r formula || [[ -n "$formula" ]]; do
  # Skip empty lines and comments
  [[ -z "$formula" || "$formula" == \#* ]] && continue

  # Trim whitespace
  formula="${formula#"${formula%%[![:space:]]*}"}"
  formula="${formula%"${formula##*[![:space:]]}"}"

  # Build command
  cmd="brew install $formula"

  if (( PRINT )); then
    # Print mode: output raw commands
    echo "$cmd"
  elif (( DRY )); then
    # Dry run mode: show what would be executed
    echo "+ $cmd"
  else
    # Execute mode: run the command
    echo "Installing: $formula"
    if ! $cmd; then
      echo "Warning: Failed to install $formula, continuing..."
    fi
  fi
done < "$CONFIG_FILE"

if [[ $PRINT -eq 0 ]] && [[ $DRY -eq 0 ]]; then
  echo "Homebrew packages installation complete!"
fi
