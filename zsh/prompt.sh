autoload -Uz vcs_info
autoload -Uz edit-command-line

# git info in prompt
zstyle ':vcs_info:git*' formats " %F{yellow}(%b)%f"
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes false

setopt prompt_subst
precmd() {
    EXIT=$?
    vcs_info
    exit_code_str=""
    if [ $EXIT -ne 0 ] ; then
        exit_code_str="%F{red}$EXIT%f|"      # Add red if exit code non 0
    fi
}

# Vi mode
function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]]; then
        echo -ne '\e[1 q'  # Block cursor for normal mode
    else
        echo -ne '\e[5 q'  # Beam cursor for insert mode
    fi
}

zle -N zle-keymap-select
bindkey -v
export KEYTIMEOUT=1

zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# Final prompt
PROMPT='${exit_code_str}%F{green}[%f%D{%H:%M:%S} %F{green}%B%~%b${vcs_info_msg_0_}%F{green}]%f$ '
