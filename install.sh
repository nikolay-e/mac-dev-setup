#!/usr/bin/env bash
# mac-dev-setup installer - secure, vetted development environment
set -euo pipefail

# --- Helper Functions ---
source "$(dirname "$0")/tasks/common.sh"

# --- Parse Arguments ---
parse_common_args "mac-dev-setup installer - secure, vetted development environment" "$@"

# --- Main Script ---
echo "🚀 mac-dev-setup Installer"
echo "=========================="
echo "This script will set up your development environment with verified, offline-capable tools."
echo ""

info "The following actions will be performed:"

# List Homebrew packages
echo "📦 Install Homebrew Packages:"
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^[[:space:]]*brew[[:space:]]+\"([^\"]+)\" ]]; then
        echo "    • ${BASH_REMATCH[1]}"
    fi
done < Brewfile

# List Pipx packages
echo ""
echo "🐍 Install Python CLI Tools:"
while IFS= read -r package || [[ -n "$package" ]]; do
    [[ -n "$package" && "$package" != \#* ]] && echo "    • $package"
done < pipx.txt

# List other actions
echo ""
echo "⚙️  Additional Setup:"
echo "    • Create symlinks for aliases and shell configuration"
echo "    • Configure your shell (~/.zshrc) to load the environment"
echo "    • Disable telemetry for all installed tools"
echo ""

# Confirm before proceeding (skip in dry-run and print modes)
if [[ $DRY -eq 0 && $PRINT -eq 0 ]]; then
    read -p "Continue with installation? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# --- Execute Installation Tasks ---
if [[ $DRY -eq 1 ]]; then
    info "Dry run mode - showing what would be installed..."
elif [[ $PRINT -eq 1 ]]; then
    info "Print mode - showing commands..."
else
    info "Starting installation..."
fi

# Pass flags to sub-scripts
SCRIPT_FLAGS=()
[[ $DRY -eq 1 ]] && SCRIPT_FLAGS+=("--dry-run")
[[ $PRINT -eq 1 ]] && SCRIPT_FLAGS+=("--print")

if ! bash "tasks/brew.install.sh" "${SCRIPT_FLAGS[@]+"${SCRIPT_FLAGS[@]}"}"; then
    echo "❌ Error: Homebrew task failed." >&2
    exit 1
fi

if ! bash "tasks/python.install.sh" "${SCRIPT_FLAGS[@]+"${SCRIPT_FLAGS[@]}"}"; then
    echo "❌ Error: Python task failed." >&2
    exit 1
fi

# Generate sheldon plugins configuration
if [[ $DRY -eq 0 && $PRINT -eq 0 ]]; then
    if command -v node >/dev/null 2>&1; then
        info "Configuring Zsh plugins..."
        node scripts/generate-plugins.js
    else
        echo "⚠️  Warning: Node.js not found, skipping sheldon plugin configuration"
        echo "💡 Tip: Install Node LTS with 'nvm install --lts' then run 'npm run generate-plugins'"
    fi
elif [[ $DRY -eq 1 ]]; then
    echo "+ Generate sheldon plugins.toml from package.json"
fi

# Apply security hardening (skip in dry-run and print modes)
if [[ $DRY -eq 0 && $PRINT -eq 0 ]]; then
    if ! bash "tasks/apply-security-settings.sh"; then
        echo "⚠️  Warning: Security hardening failed, but continuing..." >&2
    fi
else
    echo "+ Configure security settings (telemetry disabled, offline mode)"
fi

info "✅ Installation complete!"
echo ""
echo "🔒 Your environment is configured for security:"
echo "   • No telemetry or analytics"
echo "   • No automatic updates"
echo "   • All tools work offline"
echo ""
echo "📋 Next steps:"
echo "   1. Restart your terminal"
echo "   2. Run 'learn-aliases' to explore available shortcuts"
echo ""
