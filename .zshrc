# Load personal aliases
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# Set environment variables
export EDITOR='nvim'
export VISUAL='nvim'

# Customize the shell prompt for Git projects
#autoload -U colors && colors
#setopt PROMPT_SUBST
#PROMPT='%F{cyan}%~%f $(git_prompt_info)%F{normal}$ '