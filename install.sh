#!/usr/bin/env bash
# mac-dev-setup installer - secure, vetted development environment
set -euo pipefail

# --- Helper Functions ---
# Default flag values
DRY=0
YES=0

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions for consistent output
info() {
    printf "${BLUE}[*]${NC} %s\n" "$1"
}

msg_ok() {
    printf "${GREEN}[+]${NC} %s\n" "$1"
}

msg_err() {
    printf "${RED}[-]${NC} %s\n" "$1"
}

msg_warn() {
    printf "${YELLOW}[!]${NC} %s\n" "$1"
}

msg_info() {
    printf "${BLUE}[*]${NC} %s\n" "$1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Execute commands with dry-run support
run_cmd() {
    if (( DRY )); then
        echo "+ $*"
    else
        "$@"
    fi
}

# --- Parse Arguments ---
while (( "$#" )); do
    case $1 in
        --dry-run)
            DRY=1
            ;;
        --yes)
            YES=1
            ;;
        --help)
            echo "mac-dev-setup installer - secure, vetted development environment"
            echo ""
            echo "Usage: $0 [--dry-run] [--yes]"
            echo "  --dry-run    Show what would be installed without making changes"
            echo "  --yes        Skip interactive prompts and proceed automatically"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
    shift
done

# --- Main Script ---
echo "mac-dev-setup Installer"
echo "=========================="
echo "This script will set up your development environment with verified, offline-capable tools."
echo ""

# Check if Xcode Command Line Tools are installed
if ! xcode-select -p &>/dev/null; then
    msg_err "Xcode Command Line Tools are not installed."
    echo ""
    echo "Please install them first by running:"
    echo "  xcode-select --install"
    echo ""
    echo "After installation completes, run this installer again."
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew is not installed."
    echo ""
    echo "Please install Homebrew first by running:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo ""
    echo "After installation, follow the instructions to add Homebrew to your PATH."
    exit 1
fi

# Check if Zsh is the default shell
if [[ "$SHELL" != */zsh ]]; then
    echo "Warning: Your default shell is not Zsh (currently: $SHELL)"
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
echo "Install Homebrew Packages:"
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^[[:space:]]*brew[[:space:]]+\"([^\"]+)\" ]]; then
        echo "    • ${BASH_REMATCH[1]}"
    fi
done < Brewfile


# List other actions
echo ""
echo "Additional Setup:"
echo "    • Install pre-commit via pipx"
echo "    • Create symlinks for aliases and shell configuration"
echo "    • Configure your shell (~/.zshrc) to load the environment"
echo "    • Disable telemetry for all installed tools"
echo ""

# Confirm before proceeding (skip in dry-run and yes modes)
if [[ $DRY -eq 0 && $YES -eq 0 ]]; then
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
else
    info "Starting installation..."
fi

# --- Install Homebrew Packages ---
install_homebrew_packages() {
    # Environment variables for current session only
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_AUTO_UPDATE=1

    if (( DRY )); then
        run_cmd brew bundle --file="./Brewfile" --dry-run
    else
        run_cmd brew bundle --file="./Brewfile"
        info "Homebrew packages installation complete!"
    fi
}


# --- Install pipx packages ---
install_pipx_packages() {
    if (( DRY )); then
        echo "+ pipx install pre-commit"
    else
        if command_exists pipx; then
            if pipx list | grep -q "pre-commit"; then
                msg_info "pre-commit already installed via pipx"
            else
                pipx install pre-commit
                msg_ok "Installed pre-commit via pipx"
            fi
        else
            msg_warn "pipx not found, skipping pre-commit installation"
        fi
    fi
}

# --- Create Configuration Symlinks ---
create_symlinks() {
    local source="$PWD/zsh_config.sh"
    local target="$HOME/.zsh_config.sh"

    if [[ ! -f "$source" ]]; then
        echo "Warning: Source file not found: $source" >&2
        return 1
    fi

    if (( DRY )); then
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
}

# Execute installation tasks
install_homebrew_packages
install_pipx_packages
create_symlinks

# Configure shell to source zsh_config.sh
if [[ $DRY -eq 0 ]]; then
    info "Configuring shell profile..."

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

    # Install fzf keybindings
    FZF_INSTALL_SCRIPT="$(brew --prefix)/opt/fzf/install"
    if [[ -x "$FZF_INSTALL_SCRIPT" ]]; then
        info "Installing fzf keybindings..."
        if ! "$FZF_INSTALL_SCRIPT" --key-bindings --completion --no-update-rc --no-bash --no-fish; then
            echo "Warning: fzf keybindings installation failed"
            echo "   You can manually install them later by running: $FZF_INSTALL_SCRIPT"
        fi
    else
        echo "Warning: fzf install script not found. Make sure fzf is installed via Homebrew."
    fi
elif [[ $DRY -eq 1 ]]; then
    echo "+ Add 'source ~/.zsh_config.sh' to ~/.zshrc"
    echo "+ Install fzf keybindings"
fi

# Configure Sheldon for Zsh plugins
if [[ $DRY -eq 0 ]]; then
    info "Configuring Zsh plugins with Sheldon..."

    # Create Sheldon config directory
    SHELDON_CONFIG_DIR="$HOME/.config/sheldon"
    mkdir -p "$SHELDON_CONFIG_DIR"

    # Check if plugins.toml already exists and is current
    if [ -f "$SHELDON_CONFIG_DIR/plugins.toml" ] && diff -q ./plugins.toml "$SHELDON_CONFIG_DIR/plugins.toml" >/dev/null 2>&1; then
        msg_info "Sheldon plugins.toml is already up to date"
    else
        # Copy plugins.toml to Sheldon config directory
        if cp ./plugins.toml "$SHELDON_CONFIG_DIR/plugins.toml"; then
            msg_ok "Updated Sheldon configuration"
        else
            msg_err "Failed to copy plugins.toml"
            exit 1
        fi
    fi

    # Install plugins with Sheldon
    if command_exists sheldon; then
        msg_info "Installing Zsh plugins..."
        if sheldon lock; then
            msg_ok "Installed Zsh plugins successfully"
        else
            msg_warn "Sheldon plugin installation failed"
            echo "   You can manually install them later with: sheldon lock"
        fi
    else
        msg_warn "Sheldon not found, skipping plugin installation"
        echo "   Make sure Sheldon is installed via Homebrew"
    fi
elif [[ $DRY -eq 1 ]]; then
    echo "+ Copy plugins.toml to ~/.config/sheldon/"
    echo "+ Install Zsh plugins with 'sheldon lock'"
fi

# Configure Starship prompt
if [[ $DRY -eq 0 ]]; then
    info "Configuring Starship prompt..."

    # Create starship config directory
    mkdir -p "$HOME/.config"

    # Copy starship.toml to user config directory
    if cp ./starship.toml "$HOME/.config/starship.toml"; then
        msg_ok "Installed Starship configuration"
    else
        msg_err "Failed to copy starship.toml"
        exit 1
    fi
elif [[ $DRY -eq 1 ]]; then
    echo "+ Copy starship.toml to ~/.config/"
fi

# Setup modular alias system
if [[ $DRY -eq 0 ]]; then
    info "Setting up modular alias system..."

    # Create modular config directory
    MODULES_CONFIG_DIR="$HOME/.config/mac-dev-setup/modules"
    mkdir -p "$MODULES_CONFIG_DIR"

    # Copy modules to user config directory
    if cp -r ./modules/* "$MODULES_CONFIG_DIR/"; then
        msg_ok "Installed modular alias system"
    else
        msg_err "Failed to copy modules"
        exit 1
    fi

    # Set proper permissions
    chmod +x "$MODULES_CONFIG_DIR"/*.sh

    # Install learn-aliases script
    mkdir -p "$HOME/.local/bin"
    if cp ./scripts/learn-aliases.sh "$HOME/.local/bin/learn-aliases" 2>/dev/null; then
        chmod +x "$HOME/.local/bin/learn-aliases"
        msg_ok "Installed learn-aliases command"
    else
        msg_warn "Failed to install learn-aliases to ~/.local/bin/"
        echo "   You can run it directly from: ./scripts/learn-aliases.sh"
    fi

    # Create local customization template if it doesn't exist
    LOCAL_CONFIG="$HOME/.config/mac-dev-setup/local.sh"
    if [ ! -f "$LOCAL_CONFIG" ]; then
        cat > "$LOCAL_CONFIG" << 'EOF'
#!/bin/bash
# shellcheck shell=bash
# --------------------------------------------------------------------
## Local Customizations
# --------------------------------------------------------------------
# This file is for your personal aliases and overrides.
# It's loaded after all modules, so you can override anything.
# This file is ignored by git, so your customizations won't conflict.

# Example: Override a default alias
# alias gs='git status -sb'

# Example: Add your own aliases
# alias myproject='cd ~/code/my-important-project'

# Example: Add environment variables
# export MY_API_KEY="your-key-here"

# Example: Override function behavior
# gp() {
#     git push "$@" && echo "Push completed successfully!"
# }
EOF
        msg_ok "Created local customization template"
        msg_info "Edit ~/.config/mac-dev-setup/local.sh to add your personal aliases"
    else
        msg_info "Local customization file already exists"
    fi
elif [[ $DRY -eq 1 ]]; then
    echo "+ Create ~/.config/mac-dev-setup/modules/"
    echo "+ Copy modular alias files"
    echo "+ Create local customization template"
fi

# Security settings are handled by environment variables set during installation
if [[ $DRY -eq 1 ]]; then
    echo "+ Configure security settings (telemetry disabled, offline mode)"
fi

info "Installation complete!"
echo ""
echo "Your environment is configured for security:"
echo "   • No telemetry or analytics"
echo "   • No automatic updates"
echo "   • All tools work offline"
echo ""
echo "Modular alias system installed:"
echo "   • Aliases organized by topic in ~/.config/mac-dev-setup/modules/"
echo "   • Personal customizations: ~/.config/mac-dev-setup/local.sh"
echo "   • Version management: Use 'mise' for all languages"
echo ""
echo "Next steps:"
echo "   1. Restart your terminal"
echo "   2. Run 'learn-aliases' to browse your new shortcuts"
echo "   3. Edit ~/.config/mac-dev-setup/local.sh for personal aliases"
echo ""
