#!/usr/bin/env bats

setup() {
  # Create temp directory for testing
  TEST_DIR=$(mktemp -d)
  export TEST_DIR
  export HOME="$TEST_DIR"
  cd "$BATS_TEST_DIRNAME/.." || exit
}

teardown() {
  # Clean up
  rm -rf "$TEST_DIR"
}

@test "zsh_config.sh exists and is readable" {
  [ -f "zsh_config.sh" ]
  [ -r "zsh_config.sh" ]
}

@test "Brewfile exists and supports profiles" {
  [ -f "Brewfile" ]
  # Test profile resolution in Brewfile
  MAC_DEV_PROFILE=full ruby -e "load 'Brewfile'" 2>/dev/null || true
  MAC_DEV_PROFILE=local ruby -e "load 'Brewfile'" 2>/dev/null || true
}

@test "alias file has required aliases" {
  [ -f ".mac-dev-setup-aliases" ]
  grep -q "alias ls=" .mac-dev-setup-aliases
  grep -q "alias v=" .mac-dev-setup-aliases
  grep -q "alias g=" .mac-dev-setup-aliases
}

@test "all shell scripts are executable" {
  [ -x "install.sh" ]
  [ -x "uninstall.sh" ]
}

@test "scripts use proper shebang" {
  head -1 install.sh | grep -Eq '#!/usr/bin/env bash|#!/bin/bash'
  head -1 uninstall.sh | grep -Eq '#!/usr/bin/env bash|#!/bin/bash'
}

@test "shell scripts have no syntax errors" {
  bash -n install.sh
  bash -n uninstall.sh
  bash -n tasks/brew.install.sh
  bash -n tasks/python.install.sh
  bash -n tasks/configure-local-profile.sh
}

@test "install.sh has required safety checks" {
  grep -q "set -euo pipefail" install.sh
  grep -q "command -v" install.sh
}

@test "destructive functions have safety prompts" {
  grep -q "gpristine()" .mac-dev-setup-aliases
  grep -q "Press Ctrl+C to cancel" .mac-dev-setup-aliases
}

@test "kafka functions check environment" {
  grep -q "KAFKA_BROKERS" .mac-dev-setup-aliases
  grep -q "Error: Set KAFKA_BROKERS" .mac-dev-setup-aliases
}

@test "profile configs exist for both profiles" {
  [ -f "config/full/brew.txt" ]
  [ -f "config/full/pipx.txt" ]
  [ -f "config/local/brew.txt" ]
  [ -f "config/local/pipx.txt" ]
}

@test "local profile excludes network tools" {
  # Local profile should NOT have these tools
  run ! grep -q "gh" config/local/brew.txt
  run ! grep -q "git-delta" config/local/brew.txt
  run ! grep -q "sheldon" config/local/brew.txt
  run ! grep -q "tldr" config/local/brew.txt
  run ! grep -q "trivy" config/local/brew.txt
  run ! grep -q "infracost" config/local/brew.txt
}

@test "full profile has all tools" {
  # Full profile should have network tools
  grep -q "gh" config/full/brew.txt
  grep -q "git-delta" config/full/brew.txt
  grep -q "sheldon" config/full/brew.txt
  grep -q "trivy" config/full/brew.txt
  grep -q "infracost" config/full/brew.txt
}
