#!/usr/bin/env bash
# learn-aliases.sh - Browse and search shell aliases
# Simple reference tool for mac-dev-setup aliases

set -euo pipefail

# Configuration
MODULES_DIR="$HOME/.config/mac-dev-setup/modules"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print usage information
usage() {
    printf "%b%s%b\n" "$BLUE" "learn-aliases - Browse and search mac-dev-setup aliases" "$NC"
    echo ""
    echo "Usage:"
    echo "  learn-aliases              # List all aliases by category"
    echo "  learn-aliases <search>     # Search aliases containing <search>"
    echo "  learn-aliases --help       # Show this help"
    echo ""
    echo "Examples:"
    echo "  learn-aliases              # Show all aliases"
    echo "  learn-aliases git          # Show git-related aliases"
    echo "  learn-aliases docker       # Show docker aliases"
    echo ""
}

# Check if modules directory exists
check_modules() {
    if [ ! -d "$MODULES_DIR" ]; then
        printf "%b%s%b %s\n" "$YELLOW" "[!]" "$NC" "Modules directory not found: $MODULES_DIR"
        echo "Make sure you've run the mac-dev-setup installer first"
        exit 1
    fi
}

# List aliases from a specific module file
list_module_aliases() {
    local module_file="$1"
    local module_name
    module_name=$(basename "$module_file" .sh)

    # Extract aliases and functions
    local aliases functions
    aliases=$(grep -E "^alias " "$module_file" 2>/dev/null | sed 's/alias //' || true)
    functions=$(grep -E "^[a-zA-Z_][a-zA-Z0-9_]*\(\)" "$module_file" 2>/dev/null | sed 's/().*//' || true)

    if [ -n "$aliases" ] || [ -n "$functions" ]; then
        printf "\n%b%s%b\n" "$CYAN" "=== ${module_name^} ===" "$NC"

        if [ -n "$aliases" ]; then
            echo "$aliases" | while IFS='=' read -r alias_name alias_cmd; do
                # Clean up the command (remove quotes)
                alias_cmd=$(echo "$alias_cmd" | sed "s/^['\"]//;s/['\"]$//")
                printf "  %b%-12s%b %s\n" "$GREEN" "$alias_name" "$NC" "$alias_cmd"
            done
        fi

        if [ -n "$functions" ]; then
            echo "$functions" | while read -r func_name; do
                printf "  %b%-12s%b %s\n" "$YELLOW" "$func_name()" "$NC" "function"
            done
        fi
    fi
}

# Search for aliases containing a pattern
search_aliases() {
    local search_term="$1"
    local found=false

    printf "%b%s%b %s\n" "$BLUE" "Searching for:" "$NC" "$search_term"

    for module_file in "$MODULES_DIR"/*.sh; do
        [ -f "$module_file" ] || continue

        local module_name
        module_name=$(basename "$module_file" .sh)

        # Search in aliases and functions
        local matches
        matches=$(grep -E "(^alias .*$search_term|^[a-zA-Z_][a-zA-Z0-9_]*\(\).*#.*$search_term)" "$module_file" 2>/dev/null || true)

        if [ -n "$matches" ]; then
            if [ "$found" = false ]; then
                echo ""
                found=true
            fi

            printf "%b%s%b\n" "$CYAN" "=== ${module_name^} ===" "$NC"
            echo "$matches" | while IFS= read -r line; do
                if [[ "$line" =~ ^alias ]]; then
                    # Parse alias
                    alias_def=${line#alias }
                    alias_name=$(echo "$alias_def" | cut -d'=' -f1)
                    alias_cmd=$(echo "$alias_def" | cut -d'=' -f2- | sed "s/^['\"]//;s/['\"]$//")
                    printf "  %b%-12s%b %s\n" "$GREEN" "$alias_name" "$NC" "$alias_cmd"
                elif [[ "$line" =~ ^[a-zA-Z_] ]]; then
                    # Parse function
                    func_name=${line%%\(\)*}
                    printf "  %b%-12s%b %s\n" "$YELLOW" "$func_name()" "$NC" "function"
                fi
            done
        fi
    done

    if [ "$found" = false ]; then
        printf "%b%s%b No aliases found matching '%s'\n" "$YELLOW" "[!]" "$NC" "$search_term"
    fi
}

# List all aliases by category
list_all_aliases() {
    printf "%b%s%b\n" "$BLUE" "mac-dev-setup aliases and functions:" "$NC"

    for module_file in "$MODULES_DIR"/*.sh; do
        [ -f "$module_file" ] || continue
        list_module_aliases "$module_file"
    done

    echo ""
    printf "%b%s%b Use 'learn-aliases <search>' to find specific aliases\n" "$BLUE" "Tip:" "$NC"
}

# Main script
main() {
    # Handle help flag
    if [ $# -gt 0 ] && [ "$1" = "--help" ]; then
        usage
        exit 0
    fi

    # Check if modules exist
    check_modules

    # Handle search vs list all
    if [ $# -eq 0 ]; then
        list_all_aliases
    else
        search_aliases "$1"
    fi
}

main "$@"
