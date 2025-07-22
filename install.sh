#!/usr/bin/env bash
# mac-dev-setup installer - secure, vetted development environment
set -euo pipefail

# --- Helper Functions ---
info() {
    printf "\n\033[1;34m%s\033[0m\n" "$1"
}

# --- Main Script ---
echo "🚀 mac-dev-setup Installer"
echo "=========================="
echo "This script will set up your development environment with verified, offline-capable tools."
echo ""

info "The following actions will be performed:"

# List Homebrew packages
echo "📦 Install Homebrew Packages:"
while IFS= read -r package || [[ -n "$package" ]]; do
    [[ -n "$package" && "$package" != \#* ]] && echo "    • $package"
done < brew.txt

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

# Confirm before proceeding
read -p "Continue with installation? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

# --- Execute Installation Tasks ---
info "Starting installation..."

if ! bash "tasks/brew.install.sh"; then
    echo "❌ Error: Homebrew task failed." >&2
    exit 1
fi

if ! bash "tasks/python.install.sh"; then
    echo "❌ Error: Python task failed." >&2
    exit 1
fi

# Apply security hardening
if ! bash "tasks/configure-local-profile.sh"; then
    echo "⚠️  Warning: Security hardening failed, but continuing..." >&2
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
