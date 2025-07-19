# mac-dev-setup 🚀

**Set up your Mac development environment with modern tools and configuration.**

CLI tools, shell configuration, and automated dependency management for macOS developers.

## Why mac-dev-setup?

✅ **Modern Tools**: Replace traditional tools with faster alternatives
✅ **Cross-Architecture**: Works on both Intel and Apple Silicon Macs
✅ **Automated Updates**: Dependencies update automatically via Dependabot
✅ **Safe & Idempotent**: Run multiple times without breaking your setup
✅ **Backup System**: Preserves your existing configurations

## Quick Start

```bash
git clone https://github.com/nikolay-e/mac-dev-setup.git
cd mac-dev-setup
./install.sh
```

The script validates the installation and prompts you to restart your terminal.

## What You Get

### Modern CLI Tools
```bash
# Before              # After
ls                  →   eza                # Modern file listings
cat file.txt        →   bat file.txt       # Syntax highlighted output
find . -name "*.js" →   fd "*.js"          # Fast file search
grep "TODO"         →   rg "TODO"          # Fast text search
cd ~/projects       →   z projects         # Smart directory jumping
```

### Development Shortcuts
```bash
# Git workflows
gs              # git status (clean view)
ga .            # git add all
gc "fix bug"    # git commit with message
gp              # git push
glog            # commit history

# Development shortcuts
serve           # HTTP server (current directory)
update          # Update all tools (brew + python + plugins)
zj              # Launch terminal multiplexer
killport 3000   # Kill process on port 3000

# Git workflows (enhanced)
lg              # LazyGit TUI for Git operations
gwip            # Quick work-in-progress commit
prc             # Create GitHub PR with template
prchecks        # Check CI status from terminal
gbclean         # Remove merged branches

# Kubernetes workflows (600+ aliases)
k get pods      # Kubectl shortcuts (k=kubectl)
kgpo            # Get pods with wide output
klogft          # Follow logs with tail
kexec pod bash  # Quick pod shell access
kdebug          # Spin up debug pod
k9              # Kubernetes cluster TUI (k9s)
kctx            # Switch Kubernetes contexts

# Infrastructure as Code (2025 Edition)
tf              # Terraform shorthand
tfapply         # Plan and apply safely
tfsec           # Security scan with Trivy
tfcost          # Cost estimation with Infracost
tfdocs          # Auto-generate documentation
tfuse 1.6.6     # Switch Terraform versions with tenv

# Data streaming (Kafka)
kcatc my-topic  # Consume Kafka messages
kcat-tail topic # Tail last 10 messages
```

### Terminal Experience
- **Starship Prompt**: Shows git status, languages, and context
- **Auto-suggestions**: Based on your command history
- **Syntax Highlighting**: Real-time command validation
- **Tab Completion**: Context-aware completions

## Real-World Usage Examples

### Daily Development Workflow
```bash
# Navigate to project (from anywhere)
z my-project

# Quick file overview with git status
eza -la

# Search for configuration files
fd config

# Find all TODO comments
rg "TODO|FIXME" --type js

# View file with syntax highlighting
bat src/app.js

# Start development server
serve
```

### Git & Project Management
```bash
# Quick status check
gs                # Short status
gss               # Full status
gstat             # Verbose status

# Interactive Git operations with TUI
lg

# Advanced commit workflows
gwip              # Quick work-in-progress commit
gsync             # Sync with upstream (fetch + rebase)
gfix HEAD~2       # Create fixup commit for older commit
gsquash           # Interactive squash with autosquash

# Commit history
glg               # Enhanced graph log with colors
glog              # Standard oneline graph

# Branch management
gbclean           # Remove merged branches
gpristine         # Hard reset + clean (nuclear option)
gundo-hard        # Hard reset last commit

# GitHub CLI integration
prc               # Create PR with template
prchecks          # Check CI status
prco 123          # Checkout PR #123
```

### Kubernetes & Docker Workflows
```bash
# Switch between K8s contexts
kctx production
kns default

# Interactive cluster management
k9

# Multi-pod log tailing with color coding
kstern -l app=myservice

# Advanced debugging (with kubectl plugins)
kdebug            # Spin up netshoot debug pod
ktree deploy app  # Visualize object hierarchy
kneat get pod     # Clean YAML output
kaccess           # Check RBAC permissions

# Resource analysis
ktop-cpu          # Top pods by CPU usage
ktop-mem          # Top pods by memory usage
kclean            # Remove succeeded pods

# Quick operations
kgpo              # Get pods with wide output
klogft            # Follow logs with tail
kexec pod bash    # Quick shell access
kpf svc/app 8080  # Port forward

# Container analysis
dive myimage:latest  # Analyze Docker layers and optimize
```

### Infrastructure as Code Workflows
```bash
# Modern version management with tenv (replaces tfenv)
tfuse 1.6.6       # Switch to Terraform 1.6.6
tflist            # List available versions
tfinstall 1.7.0   # Install new version

# Terraform shortcuts save keystrokes daily
tf init && tfp    # terraform init && terraform plan
tfapply           # Plan and apply safely with confirmation
tfdestroy-safe    # Interactive destroy with safety prompt

# Security and cost analysis
tfsec             # Security scan with Trivy (replaces tfsec)
tfcost            # Cost estimation with Infracost
tfdocs            # Auto-generate module documentation

# Workspace management with variables
tfwswitch dev     # Switch to dev workspace with dev.tfvars

# Validate and format code
tfv && tff        # terraform validate && terraform fmt -recursive
```

### Data Streaming & Kafka
```bash
# Set Kafka broker environment
export KAFKA_BROKERS="localhost:9092"

# Produce and consume messages
echo '{"user": "alice"}' | kcatp user-events
kcatc user-events

# Tail recent messages with JSON formatting
kcat-tail user-events | jq .

# Inspect cluster metadata
kcatl  # List topics, partitions, brokers
```

### Modern Shell Automation
```bash
# Convert CLI output to JSON for processing
ps aux | jc --ps | jq '.[] | select(.cpu_percent > 50)'

# Find large files with structured data
ls -la | jc --ls | jq '.[] | select(.size > 1000000)'

# Process disk usage data
df -h | jc --df | jq '.[] | select(.use_percent > 80)'

# Quality gates before commits
precommit
```

### Python Development
```bash
# Python 3.12 ready out of the box
python --version  # Python 3.12.4

# Install CLI tools globally
pipx install httpie

# Tools auto-update via Dependabot
```

## Performance Comparison

| Task | Traditional | mac-dev-setup | Improvement |
|------|-------------|---------------|-------------|
| File listing | `ls -la` | `eza -la` | Faster with icons |
| Text search | `grep -r "pattern"` | `rg "pattern"` | Faster search |
| File find | `find . -name "*.js"` | `fd "*.js"` | Faster find |
| File viewing | `cat file.txt` | `bat file.txt` | Syntax highlighting |
| Directory navigation | `cd ../../../projects` | `z projects` | Smart jumping |

## Installation Details

The install script automatically:
1. **Detects your Mac architecture** (Intel/Apple Silicon)
2. **Installs 40+ CLI tools** via Homebrew
3. **Configures Python 3.12** with pyenv and Node.js LTS with nvm
4. **Sets up mise** for runtime version management
5. **Creates 600+ aliases** and workflows (Git, K8s, IaC, data streaming)
6. **Validates all installations** with ✅/❌ indicators
7. **Prompts for terminal restart** to activate everything

## Maintenance Made Easy

```bash
# Update everything (Homebrew + Python + shell plugins)
update

# See what's outdated
brew outdated && pipx list --outdated

# Uninstall (keeps tools, removes configs)
./uninstall.sh
```

## Automated Dependency Updates

Dependencies update automatically via GitHub's Dependabot:
- ✅ Shell plugins (zsh-autosuggestions, zsh-syntax-highlighting)
- ✅ Python packages (treemapper, tldr.py, yq, jq)
- ✅ GitHub Actions (checkout, shellcheck, bats)

Homebrew tools update together via `brew upgrade` for reliability.

## Customization

### Add Your Own Tools
```ruby
# Add to Brewfile
brew "your-tool"
cask "your-app"
```

### Custom Aliases
```bash
# Add to .mac-dev-setup-aliases
alias deploy="git push && ssh server 'cd app && git pull'"
```

### Shell Plugins
```json
// Add to package.json dependencies
"your-plugin": "git+https://github.com/user/plugin.git#v1.0.0"
```

## Troubleshooting

**Command not found after install?**
```bash
# Restart terminal or reload config
source ~/.zshrc
```

**Slow terminal startup?**
```bash
# Disable plugins temporarily
# Comment out 'eval "$(sheldon source)"' in ~/.zshrc
```

**Python/Node issues?**
```bash
# Rehash environments
pyenv rehash
nvm use --lts
```

## Requirements

- macOS 10.15+ (Intel or Apple Silicon)
- Xcode Command Line Tools: `xcode-select --install`
- Administrator access (for Homebrew installation)

---

Clone and run `./install.sh` to get started.

Created by [Nikolay-E](https://github.com/nikolay-e) • [Issues](https://github.com/nikolay-e/mac-dev-setup/issues) • [Contributing](CONTRIBUTING.md)
