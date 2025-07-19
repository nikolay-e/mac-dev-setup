#!/usr/bin/env bats

setup() {
    # Create temp directory for testing
    export TEST_DIR=$(mktemp -d)
    export HOME="$TEST_DIR"
    cd "$BATS_TEST_DIRNAME/.."
}

teardown() {
    # Clean up
    rm -rf "$TEST_DIR"
}

@test "zsh_config.sh exists and is readable" {
    [ -f "zsh_config.sh" ]
    [ -r "zsh_config.sh" ]
}

@test "Brewfile exists and has basic packages" {
    [ -f "Brewfile" ]
    grep -q "brew \"git\"" Brewfile
    grep -q "brew \"gh\"" Brewfile
}

@test "alias file has required aliases" {
    [ -f ".mac-dev-setup-aliases" ]
    grep -q "alias ls=" .mac-dev-setup-aliases
    grep -q "alias v=" .mac-dev-setup-aliases
    grep -q "alias g=" .mac-dev-setup-aliases
}

@test "all shell scripts are executable" {
    [ -x "install.sh" ]
    [ -x "update.sh" ]
    [ -x "uninstall.sh" ]
}

@test "scripts use proper shebang" {
    head -1 install.sh | grep -q "#!/bin/bash"
    head -1 update.sh | grep -q "#!/bin/bash"
    head -1 uninstall.sh | grep -q "#!/bin/bash"
}