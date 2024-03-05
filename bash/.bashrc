# Source required functions and optional prompt
source "$HOME/.bashrcd/functions.sh"
source "$HOME/.bashrcd/prompt.sh"

# Config variables
export TERM=xterm-256color
if _can_exec nvim; then
    export EDITOR=nvim
else
    export EDITOR=vim
fi
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Add ./local folders to $PATH
export MANPATH="$HOME/local/share/man:$MANPATH"
export PATH="$HOME/local/bin:$PATH"

# System
alias ..='_go_back'
alias h2d='_h2d'
alias d2h='_d2h'
alias i='_show_info'

# dircolors
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# exa
alias ll='ls -l'
if _can_exec exa; then
    alias ls='exa'
    alias ll='exa -l'
    alias tree='exa --tree -l'
fi

# fzf
trysource "~/.fzf.bash"

# extract.py script
pyalias 'extract' "$HOME/local/scripts/extract.py"

# Misc
optalias 'tmux' 'tm' 'tmux new-session -A -s main'
optalias 'nvim' 'vim' 'nvim'
optalias 'bat' 'cat' 'bat --plain'

# Zoxide
if _can_exec zoxide; then
    eval "$(zoxide init bash)"
    alias cd='_zl'
else 
    alias cd='_cl'
fi

# Finally, source the non version controlled local.sh
trysource "$HOME/.bashrcd/local.sh"
