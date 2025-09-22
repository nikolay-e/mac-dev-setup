#!/bin/bash
# shellcheck shell=bash
# --------------------------------------------------------------------
## Git Version Control
# --------------------------------------------------------------------

# Basic Git commands
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gcm='git commit -m'
alias gca='git commit --amend --no-edit'
alias gb='git branch'
alias gc='git checkout'
alias gcb='git checkout -b'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpom='git push origin main'
alias gpod='git push origin develop'
alias gl='git pull'
alias gd='git diff'
alias gdc='git diff --cached'
alias gba='git branch -a'
alias gcam='git commit -a -m'
alias gcaa='git commit -a --amend --no-edit'

# Enhanced Git workflows
alias glog='git log --oneline --decorate --graph --all'
alias glg='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias gsync='git fetch origin && git rebase origin/$(git rev-parse --abbrev-ref HEAD)'
alias gfix='git commit --fixup'
alias gsquash='git rebase -i --autosquash'
alias gstash='git stash push -m'
alias gsh='git stash'
alias gsp='git stash pop'
alias gunwip='git log -n 1 | grep -q -c "WIP" && git reset HEAD~1'
alias gundo='git reset --soft HEAD~1'
alias gundo-hard='git reset --hard HEAD~1'

# Quick Git workflows
alias wip='git add --all && git commit -m "WIP" --no-verify'
alias amen='git add --all && git commit --amend --no-edit && git push --force-with-lease'

# Git utilities
gclean() {
    echo "  DANGER: This will DELETE all uncommitted changes and untracked files!"
    echo "Press Ctrl+C to cancel, or Enter to continue..."
    read -r
    git reset --hard && git clean -dffx
    git branch --merged | grep -v "\\*\\|main\\|master" | xargs -n 1 git branch -d
}
