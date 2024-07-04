LOCAL="$HOME/.local"

# Unalias to prevent self-referencing (causes zoxide crash)
unalias cd ls 2> /dev/null

# Source required functions and optional prompt
source "$HOME/.bashrcd/functions.sh"
source "$HOME/.bashrcd/prompt.sh"

# Config variables
if [ -d "$HOME/.cargo/bin" ]; then
    PATH="$PATH:$HOME/.cargo/bin"
fi
export TERM=xterm-256color
if _can_exec nvim; then
    export EDITOR="nvim --clean"
else
    export EDITOR=vim
fi
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Add ./local folders to $PATH
export MANPATH="$LOCAL/usr/share/man:$MANPATH"
export PATH="$LOCAL/usr/bin:$PATH"
export PYTHONPATH="$LOCAL/scripts:$PYTHONPATH"

# System
alias ..='_go_back'
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
_trysource "$HOME/.fzf.bash"

# extract.py script
_pyalias 'extract' "$LOCAL/scripts/extract.py"
_pyalias 'convert' "$LOCAL/scripts/convert.py"

# Misc
_optalias 'tmux' 'tm' '_tm'
_optalias 'nvim' 'vim' 'nvim'
_optalias 'bat' 'cat' 'bat --plain'
_optalias 'realpath' 'cdr' '\cd $(realpath .)'

alias cd='_cl'

# Finally, source the non version controlled local.sh
_trysource "$HOME/.bashrcd/local.sh"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
