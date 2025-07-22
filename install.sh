#!/usr/bin/env bash
# install.sh - convenience orchestrator for mac-dev-setup
#
# This script simply calls the task scripts in order.
# You can run tasks individually from the tasks/ directory.
#
# Usage:
#   ./install.sh                    # Run all steps
#   ./install.sh --dry-run          # Show what would be done
#   ./install.sh --skip=python,node # Skip specific steps
#   ./install.sh --only=brew        # Run only specific step

set -euo pipefail

# Available installation steps
ALL_STEPS=(brew python node dotfiles validate)
STEPS=("${ALL_STEPS[@]}")

# Parse arguments
DRY_RUN=""
SKIP=""

for arg in "$@"; do
  case $arg in
    --skip=*)
      SKIP="${arg#*=}"
      ;;
    --only=*)
      IFS=',' read -r -a STEPS <<< "${arg#*=}"
      ;;
    -n|--dry-run)
      DRY_RUN="--dry-run"
      ;;
    -h|--help)
      echo "mac-dev-setup installer"
      echo ""
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  --dry-run          Show what would be installed"
      echo "  --skip=step1,step2 Skip specific steps"
      echo "  --only=step        Run only specific step(s)"
      echo ""
      echo "Available steps: ${ALL_STEPS[*]}"
      echo ""
      echo "For manual installation, see docs/00-prereqs.md"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Run $0 --help for usage"
      exit 1
      ;;
  esac
done

# Show what we're about to do
echo "mac-dev-setup installer"
echo "======================"
echo ""
echo "This will run the following steps:"
for step in "${STEPS[@]}"; do
  if [[ -z "$SKIP" ]] || [[ ",$SKIP," != *",$step,"* ]]; then
    echo "  - $step"
  fi
done
echo ""
echo "For manual installation instructions, see docs/"
echo ""

# Confirm before proceeding (unless dry-run)
if [[ -z "$DRY_RUN" ]]; then
  read -p "Continue? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
  fi
fi

# Run each step
for step in "${STEPS[@]}"; do
  # Skip if in skip list
  if [[ -n "$SKIP" ]] && [[ ",$SKIP," == *",$step,"* ]]; then
    echo "⏭️  Skipping $step (--skip specified)"
    continue
  fi

  # Check if task script exists
  TASK_SCRIPT="tasks/${step}.install.sh"
  if [[ ! -f "$TASK_SCRIPT" ]]; then
    echo "⚠️  Warning: $TASK_SCRIPT not found, skipping"
    continue
  fi

  # Run the task
  echo ""
  echo "▶️  Running $step..."
  echo "   Equivalent command: bash $TASK_SCRIPT $DRY_RUN"

  if ! bash "$TASK_SCRIPT" $DRY_RUN; then
    echo "❌ Error: $step failed"
    exit 1
  fi
done

echo ""
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal"
echo "  2. Run 'learn-aliases' to explore available shortcuts"
echo "  3. Check docs/90-validation.md to verify everything works"
