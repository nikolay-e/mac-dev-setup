# Prerequisites

**TL;DR** - Run these three commands:
```bash
xcode-select --install
softwareupdate --install-rosetta --agree-to-license  # Apple Silicon only
ssh-keygen -t ed25519 -C "your.email@example.com"
```

## 1. Xcode Command Line Tools

Required for git, compilers, and other development tools.

```bash
xcode-select --install
```

A dialog will appear. Click "Install" and wait ~10 minutes.

**Verify installation:**
```bash
xcode-select -p
# Should output: /Library/Developer/CommandLineTools
```

## 2. Rosetta 2 (Apple Silicon Macs only)

Some tools still require Intel emulation on M1/M2/M3 Macs.

```bash
# Check if you have Apple Silicon
uname -m
# If output is "arm64", run:
softwareupdate --install-rosetta --agree-to-license
```

## 3. SSH Keys (Optional but Recommended)

For GitHub/GitLab authentication without passwords.

```bash
# Check if key already exists
if [ -f ~/.ssh/id_ed25519 ]; then
    echo "SSH key already exists at ~/.ssh/id_ed25519"
    echo "Skip generation or backup existing key first"
else
    # Generate key (replace with your email)
    ssh-keygen -t ed25519 -C "your.email@example.com"
    # Press Enter to use default location
    # Enter a passphrase for better security (or press Enter for no passphrase)
fi

# Start SSH agent
eval "$(ssh-agent -s)"

# Add key to agent
ssh-add ~/.ssh/id_ed25519

# Copy public key to clipboard
pbcopy < ~/.ssh/id_ed25519.pub
```

**Security Note**: Using a passphrase adds an extra layer of security. You'll be prompted once per session.

Then add to GitHub: Settings → SSH and GPG keys → New SSH key

## 4. Admin Access

You'll need admin privileges for Homebrew installation. Test with:

```bash
sudo -v
# Enter your password when prompted
```

## Next Steps

✅ All prerequisites met? Continue to [10-homebrew.md](10-homebrew.md)
