#!/usr/bin/env bash
# mac-dev-setup installer - secure, vetted development environment
set -euo pipefail

# --- Helper Functions ---
source "$(dirname "$0")/tasks/common.sh"

# --- Parse Arguments ---
parse_common_args "mac-dev-setup installer - secure, vetted development environment

Usage: $0 [--dry-run] [--print] [--yes]
  --dry-run    Show what would be installed without making changes
  --print      Print commands that would be executed
  --yes        Skip interactive prompts and proceed automatically" "$@"

# --- Main Script ---
echo "🚀 mac-dev-setup Installer"
echo "=========================="
echo "This script will set up your development environment with verified, offline-capable tools."
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Error: Homebrew is not installed."
    echo ""
    echo "Please install Homebrew first by running:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo ""
    echo "After installation, follow the instructions to add Homebrew to your PATH."
    exit 1
fi

# Check if Zsh is the default shell
if [[ "$SHELL" != */zsh ]]; then
    echo "⚠️  Warning: Your default shell is not Zsh (currently: $SHELL)"
    echo "   This setup is optimized for Zsh. Some features may not work correctly."
    echo ""
    echo "   To switch to Zsh, run:"
    echo "     chsh -s /bin/zsh"
    echo ""

    if [[ $YES -eq 1 ]]; then
        echo "Auto-continuing despite shell warning (--yes flag provided)"
    else
        echo -n "Continue anyway? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            exit 0
        fi
    fi
fi

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

# Confirm before proceeding (skip in dry-run, print, and yes modes)
if [[ $DRY -eq 0 && $PRINT -eq 0 && $YES -eq 0 ]]; then
    read -p "Continue with installation? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
elif [[ $YES -eq 1 ]]; then
    echo "Auto-confirming installation (--yes flag provided)"
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

if ! bash "tasks/symlinks.sh" "${SCRIPT_FLAGS[@]+"${SCRIPT_FLAGS[@]}"}"; then
    echo "❌ Error: Symlinks task failed." >&2
    exit 1
fi

# Configure shell to source zsh_config.sh
if [[ $DRY -eq 0 && $PRINT -eq 0 ]]; then
    info "Configuring shell profile..."

    # Check for potential alias conflicts
    COMMON_ALIASES=("ls" "ll" "la" "cat" "grep")
    CONFLICTS_FOUND=0

    for alias_name in "${COMMON_ALIASES[@]}"; do
        if grep -q "alias $alias_name=" ~/.zshrc 2>/dev/null; then
            if [[ $CONFLICTS_FOUND -eq 0 ]]; then
                echo "⚠️  Warning: Potential alias conflicts detected in ~/.zshrc:"
                CONFLICTS_FOUND=1
            fi
            echo "   - '$alias_name' alias already defined"
        fi
    done

    if [[ $CONFLICTS_FOUND -eq 1 ]]; then
        echo "   💡 Tip: Move your custom aliases to ~/.my_aliases to preserve them"
        echo ""
    fi

    # Define markers
    BEGIN_MARKER="# BEGIN mac-dev-setup configuration"
    END_MARKER="# END mac-dev-setup configuration"

    # Check if configuration already exists
    if grep -q "$BEGIN_MARKER" ~/.zshrc 2>/dev/null; then
        echo "Configuration already exists in ~/.zshrc (will be updated)"
        # Remove existing configuration block
        sed -i '' "/$BEGIN_MARKER/,/$END_MARKER/d" ~/.zshrc
    fi

    # Add configuration block with markers
    cat >> ~/.zshrc <<EOF

$BEGIN_MARKER
# Load mac-dev-setup configuration
source ~/.zsh_config.sh
$END_MARKER
EOF

    echo "Added configuration to ~/.zshrc"

    # Create ~/.nvm directory for Node Version Manager
    if [[ ! -d ~/.nvm ]]; then
        mkdir -p ~/.nvm
        echo "Created ~/.nvm directory"
    fi

    # Install fzf keybindings
    FZF_INSTALL_SCRIPT="$(brew --prefix)/opt/fzf/install"
    if [[ -x "$FZF_INSTALL_SCRIPT" ]]; then
        info "Installing fzf keybindings..."
        if ! "$FZF_INSTALL_SCRIPT" --key-bindings --completion --no-update-rc --no-bash --no-fish; then
            echo "⚠️  Warning: fzf keybindings installation failed"
            echo "   You can manually install them later by running: $FZF_INSTALL_SCRIPT"
        fi
    else
        echo "⚠️  Warning: fzf install script not found. Make sure fzf is installed via Homebrew."
    fi
elif [[ $DRY -eq 1 ]]; then
    echo "+ Add 'source ~/.zsh_config.sh' to ~/.zshrc"
    echo "+ Create ~/.nvm directory"
    echo "+ Install fzf keybindings"
fi

# Install Node.js via nvm for plugin generation
if [[ $DRY -eq 0 && $PRINT -eq 0 ]]; then
    if ! command -v node >/dev/null 2>&1; then
        info "Installing Node.js LTS via nvm..."
        # Source nvm to make it available
        export NVM_DIR="$HOME/.nvm"
        [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"

        if command -v nvm >/dev/null 2>&1; then
            echo "Installing Node.js LTS..."
            if nvm install --lts && nvm use --lts; then
                echo "✅ Installed Node.js $(node --version)"
            else
                echo "⚠️  Warning: Node.js installation failed"
                echo "   You can manually install it later with: nvm install --lts"
            fi
        else
            echo "⚠️  Warning: nvm not available, skipping Node.js installation"
        fi
    fi
elif [[ $DRY -eq 1 ]]; then
    echo "+ Install Node.js LTS via nvm (if not present)"
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
