#!/bin/bash
# shellcheck shell=bash
# --------------------------------------------------------------------
## Core CLI Replacements & Navigation
# --------------------------------------------------------------------

# Modern CLI replacements
alias cat='bat --paging=never'
alias ls='eza'
alias l='eza -1'
alias ll='eza -l'
alias la='eza -la'
alias lt='eza -T --level=2'
alias l.='eza -la --only-dotfiles'
alias ltr='eza -la --sort=modified'
alias lsd='eza -la --only-dirs'
alias lss='eza -la --sort=size'

# Navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias cd..='cd ..'
alias ~='cd ~'
alias icloud='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs'
alias ccode='cd ~/code'
alias dev='cd ~/Development'
alias dl='cd ~/Downloads'

# Shell configuration
alias zshconfig='nvim ~/.zshrc'
alias zshrc='nvim ~/.zshrc && source ~/.zshrc'
alias reload='source ~/.zshrc'
alias hosts='sudo nvim /etc/hosts'

# Terminal utilities
alias treex='tree -I "node_modules|*.pyc|__pycache__|.git"'
alias c='clear'
alias p='pbpaste'
alias copypwd='pwd | pbcopy'

# Editor shortcuts
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias e='nvim'
alias oldvim='/usr/bin/vim'

# Make directory and change into it
mcd() {
    mkdir -p "$1" && cd "$1" || return
}

# Quick backup function
backup() {
    cp "$1"{,.bak}
}
