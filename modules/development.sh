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

alias pca='pre-commit run --all-files'
