#!/bin/bash
# shellcheck shell=bash
# --------------------------------------------------------------------
## Development Tools & Package Management
# --------------------------------------------------------------------

# Homebrew package management
alias bru='brew update && brew upgrade && brew cleanup'
alias bri='brew install'
alias brs='brew search'
alias brl='brew list'
alias brr='brew remove'
alias brc='brew cleanup'

# Node.js package management
alias ni='npm install'
alias nid='npm install -D'
alias nr='npm run'
alias nt='npm test'
alias ns='npm start'
alias nb='npm run build'
alias yi='yarn install'
alias ya='yarn add'
alias yr='yarn run'
alias ys='yarn start'
alias yt='yarn test'

# Package manager detection
pm-run() {
    if [ -f "yarn.lock" ]; then
        yarn "$@"
    elif [ -f "package-lock.json" ]; then
        npm run "$@"
    else
        echo "No lockfile found; defaulting to npm run"
        npm run "$@"
    fi
}

# Code quality
alias precommit='pre-commit run --all-files'
