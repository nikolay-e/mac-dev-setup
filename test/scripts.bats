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

@test "Brewfile exists and has valid syntax" {
  [ -f "Brewfile" ]
  # Test Brewfile syntax
  ruby -c Brewfile
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
  bash -n tasks/apply-security-settings.sh
  bash -n tasks/common.sh
}

@test "install.sh has required safety checks" {
  grep -q "set -euo pipefail" install.sh
  grep -q "read -p.*Continue" install.sh
}

@test "destructive functions have safety prompts" {
  grep -q "gclean()" .mac-dev-setup-aliases
  grep -q "Press Ctrl+C to cancel" .mac-dev-setup-aliases
}

@test "kafka functions check environment" {
  grep -q "KAFKA_BROKERS" .mac-dev-setup-aliases
  grep -q "Error: Set KAFKA_BROKERS" .mac-dev-setup-aliases
}

@test "config files exist" {
  [ -f "Brewfile" ]
  [ -f "pipx.txt" ]
}

@test "secure configuration includes vetted tools" {
  # Secure configuration should have core development tools
  grep -q '"git"' Brewfile
  grep -q '"neovim"' Brewfile
  grep -q '"docker"' Brewfile
  grep -q '"tenv"' Brewfile
  # Should NOT have unvetted network tools
  run ! grep -q '"gh"' Brewfile
  run ! grep -q '"trivy"' Brewfile
}
