#!/bin/bash
# shellcheck shell=bash
# --------------------------------------------------------------------
## System Utilities & Productivity
# --------------------------------------------------------------------

# Quick file operations
alias mkd='mkdir -p'
alias duh='du -h -d 1 | sort -h'
alias df='df -h'
alias hist='history'
alias j='jobs -l'

# Process management
alias psg='ps aux | grep -v grep | grep -i'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

killport() {
    if [ -z "$1" ]; then
        echo "Usage: killport <port_number>"
        return 1
    fi
    lsof -ti:"$1" | xargs kill -9
}

# Network utilities
localip() {
    ipconfig getifaddr "$(route get default | grep interface | awk '{print $2}')"
}
alias serve='python3 -m http.server'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias zj='zellij'
alias copykey='pbcopy < ~/.ssh/id_ed25519.pub'
alias copykey-rsa='pbcopy < ~/.ssh/id_rsa.pub'

# Archive extraction
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz) tar xzf "$1" ;;
            *.tar.xz) tar xJf "$1" ;;
            *.tar.zst) tar --use-compress-program=unzstd -xf "$1" ;;
            *.bz2) bunzip2 "$1" ;;
            *.rar) unar "$1" ;;
            *.gz) gunzip "$1" ;;
            *.tar) tar xf "$1" ;;
            *.tbz2) tar xjf "$1" ;;
            *.tgz) tar xzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *.7z) 7z x "$1" ;;
            *.zst) unzstd "$1" ;;
            *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# JSON processing and modern CLI tools
alias psj='ps aux | jc --ps'
alias lsj='eza -la | jc --ls'
alias dfj='df -h | jc --df'
alias digj='dig +short | jc --dig'
jqc() { if [ -t 1 ]; then command jq -C "$@"; else command jq "$@"; fi; }
alias jq='jqc'
alias jqs='jq -S'

# Time utilities
epoch() {
    if [ $# -eq 0 ]; then
        date +%s
    else
        date -r "$1" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -d @"$1" '+%Y-%m-%d %H:%M:%S'
    fi
}

# Navigation with zoxide
alias zz='z -'
