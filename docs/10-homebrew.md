# Homebrew Installation & Package Setup

**TL;DR** - Install Homebrew and all packages:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon
bash tasks/brew.install.sh
```

## Why Homebrew?

Homebrew manages packages without sudo, handles dependencies automatically, and works on both Intel and Apple Silicon.

> **🔒 Sensitive Environment?**
>
> Use `./install.sh --profile=local` for telemetry-free tools only.
> Safe for air-gapped environments.

## Step 1: Install Homebrew

### Apple Silicon (M1/M2/M3) Macs:
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Intel Macs:
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH (usually automatic on Intel)
echo >> ~/.zprofile
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"
```

### Verify Installation:
```bash
brew --version
# Should output: Homebrew 4.x.x
```

## Step 2: Install Development Tools

### Option A: Use the automated script (Recommended)
```bash
bash tasks/brew.install.sh
```

### Option B: Manual installation
```bash
# Install all packages from config file
brew install $(grep -v '^#' config/brew.txt | grep -v '^$')
```

### Option C: Individual packages
```bash
# Core tools
brew install git git-delta gh wget htop

# Modern CLI replacements
brew install bat eza fd ripgrep zoxide

# ... etc (see config/brew.txt for full list)
```

## Step 3: Post-Installation Setup

Some tools need additional configuration:

### 1. FZF (Fuzzy Finder)
```bash
# Install shell integration
$(brew --prefix)/opt/fzf/install --no-update-rc --key-bindings --completion
```

### 2. Node Version Manager
```bash
# Create NVM directory
mkdir -p ~/.nvm
```

## Common Issues

### "brew: command not found"
You need to add Homebrew to your PATH. Re-run the eval command from Step 1.

### "Permission denied" errors
Never use sudo with brew. If you see permission errors:
```bash
sudo chown -R $(whoami) $(brew --prefix)/*
```

### Slow downloads
Use a different Homebrew mirror:
```bash
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.aliyun.com/homebrew/homebrew-bottles
```

## Maintenance

```bash
# Update package definitions
brew update

# Upgrade all packages
brew upgrade

# Clean old versions
brew cleanup
```

## Next Steps

✅ Homebrew installed? Continue to [20-python.md](20-python.md)
