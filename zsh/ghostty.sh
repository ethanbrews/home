# Only run if we are inside Ghostty
[[ "$TERM_PROGRAM" != "ghostty" ]] && return

typeset -ga _ghostty_cmd_patterns=()
typeset -ga _ghostty_cmd_colors=()
typeset -ga _ghostty_folder_paths=()
typeset -ga _ghostty_folder_colors=()
typeset -ga _ghostty_env_vars=()
typeset -ga _ghostty_env_patterns=()
typeset -ga _ghostty_env_colors=()
typeset -g _ghostty_locked=0

_ghostty_set_tab_color() {
    printf '\033]6;1;bg;red;brightness;%s\a' "$1"
    printf '\033]6;1;bg;green;brightness;%s\a' "$2"
    printf '\033]6;1;bg;blue;brightness;%s\a' "$3"
}

tab-color() {
    _ghostty_set_tab_color "$@"
    _ghostty_locked=1
}

tab-reset() {
    printf '\033]6;1;bg;*;default\a'
    _ghostty_locked=0
}

tab-lock() { _ghostty_locked=1 }
tab-unlock() { _ghostty_locked=0 }

command-tab-colorize() {
    _ghostty_cmd_patterns+=("$1")
    # If $3 is empty, it means $2 contains the whole "R G B" string
    if [ -z "$3" ]; then
        _ghostty_cmd_colors+=("$2")
    else
        _ghostty_cmd_colors+=("$2 $3 $4")
    fi
}

folder-tab-colorize() {
    _ghostty_folder_paths+=("${1:a}")
    # If $3 is empty, the color is entirely in $2
    if [ -z "$3" ]; then
        _ghostty_folder_colors+=("$2")
    else
        _ghostty_folder_colors+=("$2 $3 $4")
    fi
}

env-tab-colorize() {
    _ghostty_env_vars+=("$1")
    _ghostty_env_patterns+=("$2")
    # For env-tab-colorize, the color starts at $3. 
    # If $4 is empty, the color is entirely in $3.
    if [ -z "$4" ]; then
        _ghostty_env_colors+=("$3")
    else
        _ghostty_env_colors+=("$3 $4 $5")
    fi
}

function ghostty_tab_precmd() {
    [[ $_ghostty_locked -eq 1 ]] && return

    if [[ ${#_ghostty_env_vars} -gt 0 ]]; then
        local i val colors
        for ((i = 1; i <= ${#_ghostty_env_vars}; i++)); do
            val="${(P)_ghostty_env_vars[$i]}"
            if [[ -n "$val" && "$val" =~ "${_ghostty_env_patterns[$i]}" ]]; then
                colors=(${=_ghostty_env_colors[$i]})
                _ghostty_set_tab_color ${colors[1]} ${colors[2]} ${colors[3]}
                return
            fi
        done
    fi
    printf '\033]6;1;bg;*;default\a'
}

function ghostty_tab_preexec() {
    [[ $_ghostty_locked -eq 1 ]] && return

    local cmd="$1"
    local exe="${cmd%% *}"
    local resolved i colors

    if [[ "$exe" == /* || "$exe" == ./* || "$exe" == ../* ]]; then
        resolved="${exe:a}"
    else
        resolved=$(whence -p "$exe" 2>/dev/null)
    fi

    if [[ -n "$resolved" && ${#_ghostty_folder_paths} -gt 0 ]]; then
        for ((i = 1; i <= ${#_ghostty_folder_paths}; i++)); do
            if [[ "$resolved" == "${_ghostty_folder_paths[$i]}"/* ]]; then
                colors=(${=_ghostty_folder_colors[$i]})
                _ghostty_set_tab_color ${colors[1]} ${colors[2]} ${colors[3]}
                return
            fi
        done
    fi

    if [[ ${#_ghostty_cmd_patterns} -gt 0 ]]; then
        for ((i = 1; i <= ${#_ghostty_cmd_patterns}; i++)); do
            if [[ "$cmd" =~ "${_ghostty_cmd_patterns[$i]}" ]]; then
                colors=(${=_ghostty_cmd_colors[$i]})
                _ghostty_set_tab_color ${colors[1]} ${colors[2]} ${colors[3]}
                return
            fi
        done
    fi
}

autoload -U add-zsh-hook
add-zsh-hook precmd  ghostty_tab_precmd
add-zsh-hook preexec ghostty_tab_preexec
