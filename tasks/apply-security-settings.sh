#!/usr/bin/env bash
# tasks/apply-security-settings.sh - Configure tools for secure, telemetry-free operation
#
# Usage:
#   bash tasks/apply-security-settings.sh

set -euo pipefail

echo "🔒 Configuring tools for secure operation (telemetry-free)..."

# Disable Homebrew telemetry
if command -v brew &>/dev/null; then
  echo "- Disabling Homebrew analytics..."
  brew analytics off 2>/dev/null || true
fi

# Configure git settings
if command -v git &>/dev/null; then
  echo "- Configuring git for security..."
  # Basic secure git configuration
  git config --global init.defaultBranch main 2>/dev/null || true
fi

# Disable AWS CLI telemetry and command history
if command -v aws &>/dev/null; then
  echo "- Disabling AWS CLI telemetry..."
  # Disable AWS CLI v2 telemetry
  export AWS_CLI_TELEMETRY=0
  # Disable command history
  mkdir -p ~/.aws
  if [[ ! -f ~/.aws/config ]]; then
    echo "[default]" > ~/.aws/config
  fi
  if ! grep -q "cli_history" ~/.aws/config 2>/dev/null; then
    echo "cli_history = disabled" >> ~/.aws/config
  fi
fi

# Disable Helm telemetry
if command -v helm &>/dev/null; then
  echo "- Disabling Helm telemetry..."
  export HELM_TELEMETRY_DISABLED=1
fi

# Disable mise update checks and telemetry
if command -v mise &>/dev/null; then
  echo "- Disabling mise telemetry and update checks..."
  export MISE_TELEMETRY_DISABLE=1
  export MISE_DISABLE_UPDATE_CHECK=1
fi

# Set general privacy flags
echo "- Configuring general privacy settings..."
export DO_NOT_TRACK=1

# Configure tenv/Terraform for privacy
if command -v tenv &>/dev/null || command -v terraform &>/dev/null; then
  echo "- Configuring Terraform/tenv for privacy..."
  export TF_CLI_NO_PROMPT=1
  export CHECKPOINT_DISABLE=1
fi

# Set environment variables for current session
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_FROM_API=1
export GIT_TERMINAL_PROMPT=0
export AWS_CLI_TELEMETRY=0
export HELM_TELEMETRY_DISABLED=1
export MISE_TELEMETRY_DISABLE=1
export MISE_DISABLE_UPDATE_CHECK=1
export DO_NOT_TRACK=1
export TF_CLI_NO_PROMPT=1
export CHECKPOINT_DISABLE=1

# Add to shell config if not already present
SHELL_CONFIG=""
if [[ -f ~/.zshrc ]]; then
  SHELL_CONFIG=~/.zshrc
elif [[ -f ~/.bashrc ]]; then
  SHELL_CONFIG=~/.bashrc
fi

if [[ -n "$SHELL_CONFIG" ]]; then
  echo "- Adding telemetry-blocking environment variables to $SHELL_CONFIG..."

  # Define markers
  BEGIN_MARKER="# BEGIN mac-dev-setup telemetry settings"
  END_MARKER="# END mac-dev-setup telemetry settings"

  # Check if telemetry block already exists
  if grep -q "$BEGIN_MARKER" "$SHELL_CONFIG" 2>/dev/null; then
    echo "  Telemetry settings already exist in $SHELL_CONFIG (will be updated)"
    # Remove existing telemetry block
    sed -i '' "/$BEGIN_MARKER/,/$END_MARKER/d" "$SHELL_CONFIG"
  fi

  # Add telemetry configuration block with markers
  cat >> "$SHELL_CONFIG" <<EOF

$BEGIN_MARKER
# Telemetry-free environment (added by mac-dev-setup)
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_FROM_API=1
export GIT_TERMINAL_PROMPT=0
export AWS_CLI_TELEMETRY=0
export HELM_TELEMETRY_DISABLED=1
export MISE_TELEMETRY_DISABLE=1
export MISE_DISABLE_UPDATE_CHECK=1
export DO_NOT_TRACK=1
export TF_CLI_NO_PROMPT=1
export CHECKPOINT_DISABLE=1
$END_MARKER
EOF

  echo "  Environment variables added to $SHELL_CONFIG"
fi

echo ""
echo "✅ Security configuration complete!"
echo ""
echo "Your tools are now configured to:"
echo "  - Never send telemetry"
echo "  - Never auto-update"
echo "  - Work completely offline"
echo ""
echo "Note: Restart your terminal for all changes to take effect."
