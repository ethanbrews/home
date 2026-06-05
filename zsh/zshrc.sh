unalias cd ls 2> /dev/null

local here=${0:a:h}

source $here/functions.sh
source $here/tenancy-cache.sh
source $here/prompt.sh
source $here/iterm2.sh

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

_trysource "$HOME/.cargo/env"
if _can_exec fzf; then
    source <(fzf --zsh)

    if _can_exec fd; then
        fzf_compgen_path() {
            fd --exclude ".git" --follow --hidden . "$1"
        }

        fzf_compgen_dir() {
            fd --exclude ".git" --follow --hidden --type d . "$1"
        }

        export FZF_ALT_C_COMMAND="fd --type d --exclude .git --follow --hidden"
        export FZF_DEFAULT_COMMAND="fd --type f --exclude .git --follow --hidden"
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
fi

_optalias 'tmux' 'tm' '_tm'
_optalias 'zellij' 'tt' '_open_zellij'
_optalias 'nvim' 'vim' 'nvim'
_optalias 'bat' 'cat' 'bat --paging=never --plain'

_optalias 'git' 'gs' 'git status --ahead-behind'
_optalias 'git' 'ga' 'git add'
_optalias 'git' 'gl' 'git log --all --decorate --oneline --graph'
_optalias 'git' 'gc' 'git commit'
_optalias 'git' 'gt' '_git_switch'
_optalias 'git' 'git-cleanup' '_git_cleanup'

chpwd() {
    _print_dir
}

_pyalias 'extract' "$scriptspath/extract.py"

setopt EXTENDED_HISTORY        # store time in history
setopt HIST_EXPIRE_DUPS_FIRST  # unique events are more usefull to me
setopt HIST_VERIFY             # Make those history commands nice
setopt INC_APPEND_HISTORY      # immediatly insert history into history file
HISTSIZE=160000                # spots for duplicates/uniques
SAVEHIST=150000                # unique events guaranteed
HISTFILE=~/.history
