# --------------------------------------------------------------------
# Environment & Editor
# --------------------------------------------------------------------
export EDITOR='nvim'
export VISUAL='nvim'
export GPG_TTY=$(tty)

# --------------------------------------------------------------------
# Source Aliases
# --------------------------------------------------------------------
# Load personal aliases from the dedicated file
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# --------------------------------------------------------------------
# Development Environment Initialization
# --------------------------------------------------------------------

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh" # This loads nvm
[ -s "$(brew --prefix nvm)/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix nvm)/etc/bash_completion.d/nvm" # This loads nvm bash_completion

# Pyenv (Python Version Manager)
if command -v pyenv 1>/dev/null 2>&1; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

# --------------------------------------------------------------------
# FZF (Fuzzy Finder)
# --------------------------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh