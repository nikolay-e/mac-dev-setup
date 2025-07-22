#!/usr/bin/env bash
# tasks/symlinks.sh - create symlinks for configuration files
#
# Usage:
#   bash tasks/symlinks.sh           # Create symlinks
#   bash tasks/symlinks.sh --dry-run # Show what would be created
#   bash tasks/symlinks.sh --print   # Print raw commands for copy-paste

set -euo pipefail

# Load common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Parse arguments
parse_common_args "Create configuration symlinks" "$@"

# Project root directory
PROJECT_ROOT="$SCRIPT_DIR/.."

# Configuration files to symlink
SYMLINK_SOURCES=(
    "$PROJECT_ROOT/.mac-dev-setup-aliases"
    "$PROJECT_ROOT/zsh_config.sh"
)

SYMLINK_TARGETS=(
    "$HOME/.mac-dev-setup-aliases"
    "$HOME/.zsh_config.sh"
)

# Create symlinks
for i in "${!SYMLINK_SOURCES[@]}"; do
    source="${SYMLINK_SOURCES[$i]}"
    target="${SYMLINK_TARGETS[$i]}"

    if [[ ! -f "$source" ]]; then
        echo "Warning: Source file not found: $source" >&2
        continue
    fi

    if (( PRINT )); then
        echo "ln -sf \"$source\" \"$target\""
    elif (( DRY )); then
        echo "+ Create symlink: $target -> $source"
    else
        # Remove existing file/symlink if it exists
        if [[ -e "$target" || -L "$target" ]]; then
            rm "$target"
        fi

        # Create symlink
        ln -sf "$source" "$target"
        echo "Created symlink: $target -> $source"
    fi
done

if [[ $DRY -eq 0 && $PRINT -eq 0 ]]; then
    echo "Symlink creation complete!"
fi
