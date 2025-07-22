#!/usr/bin/env bash
# tasks/apply-security-settings.sh - Configure tools for secure, telemetry-free operation
#
# Usage:
#   bash tasks/apply-security-settings.sh

set -euo pipefail

echo "🔒 Configuring tools for local profile (telemetry-free)..."

# Disable Homebrew telemetry
if command -v brew &>/dev/null; then
  echo "- Disabling Homebrew analytics..."
  brew analytics off 2>/dev/null || true
fi

# Disable git-delta update checks
if command -v git &>/dev/null; then
  echo "- Disabling git-delta update checks..."
  git config --global delta.check-for-updates false 2>/dev/null || true
fi

# Note: lazygit removed from project

# Set environment variables for current session
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_FROM_API=1
export GIT_TERMINAL_PROMPT=0

# Add to shell config if not already present
SHELL_CONFIG=""
if [[ -f ~/.zshrc ]]; then
  SHELL_CONFIG=~/.zshrc
elif [[ -f ~/.bashrc ]]; then
  SHELL_CONFIG=~/.bashrc
fi

if [[ -n "$SHELL_CONFIG" ]]; then
  echo "- Adding telemetry-blocking environment variables to $SHELL_CONFIG..."

  # Check if already configured
  if ! grep -q "HOMEBREW_NO_ANALYTICS" "$SHELL_CONFIG" 2>/dev/null; then
    cat >> "$SHELL_CONFIG" <<'EOF'

# Telemetry-free environment (added by mac-dev-setup)
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export GIT_TERMINAL_PROMPT=0
EOF
    echo "  Environment variables added to $SHELL_CONFIG"
  else
    echo "  Environment variables already configured"
  fi
fi

echo ""
echo "✅ Local profile configuration complete!"
echo ""
echo "Your tools are now configured to:"
echo "  - Never send telemetry"
echo "  - Never auto-update"
echo "  - Work completely offline"
echo ""
echo "Note: Restart your terminal for all changes to take effect."
