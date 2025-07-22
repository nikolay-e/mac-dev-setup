#!/usr/bin/env bash
# tasks/common.sh - Common utilities for task scripts

# Standardized argument parsing for task scripts
parse_common_args() {
  local usage="${1:-"Usage: $0 [--dry-run] [--print] [--yes]"}"
  shift || true
  DRY=0
  PRINT=0
  YES=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n|--dry-run) DRY=1 ;;
      --print) PRINT=1 ;;
      -y|--yes) YES=1 ;;
      -h|--help)
        echo "$usage"
        exit 0
        ;;
      *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
  done
  export DRY PRINT YES
}

# Standardized command execution with consistent error handling
run_cmd() {
  local cmd="$1"
  local continue_on_error="${2:-false}"

  if (( PRINT )); then
    echo "$cmd"
  elif (( DRY )); then
    echo "+ $cmd"
  else
    echo "Running: $cmd"
    if ! eval "$cmd"; then
      if [[ "$continue_on_error" == "true" ]]; then
        echo "Warning: Command failed but continuing: $cmd" >&2
        return 0  # prevent set -e from aborting
      else
        echo "Error: Command failed: $cmd" >&2
        exit 1
      fi
    fi
  fi
}

# Standardized info function
info() {
  printf "\n\033[1;34m%s\033[0m\n" "$1"
}

# Standardized warning function
warn() {
  printf "\n\033[1;33m%s\033[0m\n" "$1"
}
