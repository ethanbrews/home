unalias cd ls 2> /dev/null

local here=${0:a:h}
local scriptspath=$here/../scripts

source $here/functions.sh
source $here/prompt.sh

_trypath "$HOME/.cargo/bin"

if _can_exec nvim; then
    export EDITOR=nvim
else
    export EDITOR=vim
fi

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export CLICOLOR=1

alias ..='_go_back'
alias i='_show_info'

# dircolors
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

_trysource "$HOME/.fzf.zsh"
_trysource "$HOME/.cargo/env"
if _can_exec fzf; then
    source <(fzf --zsh)
fi

_optalias 'tmux' 'tm' '_tm'
_optalias 'zellij' 'tt' '_open_zellij'
_optalias 'nvim' 'vim' 'nvim'
_optalias 'bat' 'cat' 'bat --plain'

alias cd='_cl'

_pyalias 'extract' "$scriptspath/extract.py"

setopt EXTENDED_HISTORY        # store time in history
setopt HIST_EXPIRE_DUPS_FIRST  # unique events are more usefull to me
setopt HIST_VERIFY             # Make those history commands nice
setopt INC_APPEND_HISTORY      # immediatly insert history into history file
HISTSIZE=160000                # spots for duplicates/uniques
SAVEHIST=150000                # unique events guaranteed
HISTFILE=~/.history
