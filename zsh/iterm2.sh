typeset -ga _iterm2_cmd_patterns=()
typeset -ga _iterm2_cmd_colors=()
typeset -ga _iterm2_folder_paths=()
typeset -ga _iterm2_folder_colors=()
typeset -ga _iterm2_env_vars=()
typeset -ga _iterm2_env_patterns=()
typeset -ga _iterm2_env_colors=()
typeset -g _iterm2_locked=0
typeset -g _iterm2_python=""
typeset -g _iterm2_cached_gui_color="none"
typeset -g _iterm2_last_color_check=0
typeset -g _iterm2_script_dir=${0:a:h}

_iterm2_set_tab_color() {
    printf '\033]6;1;bg;red;brightness;%s\a' "$1"
    printf '\033]6;1;bg;green;brightness;%s\a' "$2"
    printf '\033]6;1;bg;blue;brightness;%s\a' "$3"
}

tab-color() {
    _iterm2_set_tab_color "$@"
    _iterm2_locked=1
}

tab-red() { tab-color 255 0 0 }
tab-green() { tab-color 0 255 0 }
tab-blue() { tab-color 0 0 255 }

tab-reset() {
    printf '\033]6;1;bg;*;default\a'
    _iterm2_locked=0
}

tab-lock() { _iterm2_locked=1 }
tab-unlock() { _iterm2_locked=0 }

command-tab-colorize() {
    _iterm2_cmd_patterns+=("$1")
    _iterm2_cmd_colors+=("$2 $3 $4")
}

folder-tab-colorize() {
    _iterm2_folder_paths+=("${1:a}")
    _iterm2_folder_colors+=("$2 $3 $4")
}

env-tab-colorize() {
    _iterm2_env_vars+=("$1")
    _iterm2_env_patterns+=("$2")
    _iterm2_env_colors+=("$3 $4 $5")
}

_iterm2_is_our_color() {
    [[ "$1" == "none" ]] && return 0
    local i
    for ((i = 1; i <= ${#_iterm2_cmd_colors}; i++)); do
        [[ "$1" == "${_iterm2_cmd_colors[$i]}" ]] && return 0
    done
    for ((i = 1; i <= ${#_iterm2_folder_colors}; i++)); do
        [[ "$1" == "${_iterm2_folder_colors[$i]}" ]] && return 0
    done
    for ((i = 1; i <= ${#_iterm2_env_colors}; i++)); do
        [[ "$1" == "${_iterm2_env_colors[$i]}" ]] && return 0
    done
    return 1
}

_iterm2_refresh_gui_color() {
    [[ -z "$_iterm2_python" ]] && return
    local now=$SECONDS
    (( now - _iterm2_last_color_check < 5 )) && return
    _iterm2_last_color_check=$now
    _iterm2_cached_gui_color=$("$_iterm2_python" "$_iterm2_script_dir/iterm2_check_tab_color.py" 2>/dev/null)
    [[ -z "$_iterm2_cached_gui_color" ]] && _iterm2_cached_gui_color="none"
}

[[ -z "$ITERM_SESSION_ID" ]] && return

local _candidates=(/Applications/iTerm.app/Contents/Resources/iterm2_env/versions/*/bin/python3(N))
[[ ${#_candidates} -gt 0 ]] && _iterm2_python="${_candidates[-1]}"

function iterm2_tab_precmd() {
    [[ $_iterm2_locked -eq 1 ]] && return
    _iterm2_refresh_gui_color
    _iterm2_is_our_color "$_iterm2_cached_gui_color" || return
    if [[ ${#_iterm2_env_vars} -gt 0 ]]; then
        local i val colors
        for ((i = 1; i <= ${#_iterm2_env_vars}; i++)); do
            val="${(P)_iterm2_env_vars[$i]}"
            if [[ -n "$val" && "$val" =~ "${_iterm2_env_patterns[$i]}" ]]; then
                colors=(${=_iterm2_env_colors[$i]})
                _iterm2_set_tab_color ${colors[1]} ${colors[2]} ${colors[3]}
                return
            fi
        done
    fi
    printf '\033]6;1;bg;*;default\a'
}

function iterm2_tab_preexec() {
    [[ $_iterm2_locked -eq 1 ]] && return
    _iterm2_is_our_color "$_iterm2_cached_gui_color" || return
    local cmd="$1"
    local exe="${cmd%% *}"
    local resolved i colors
    if [[ "$exe" == /* || "$exe" == ./* || "$exe" == ../* ]]; then
        resolved="${exe:a}"
    else
        resolved=$(whence -p "$exe" 2>/dev/null)
    fi
    if [[ -n "$resolved" && ${#_iterm2_folder_paths} -gt 0 ]]; then
        for ((i = 1; i <= ${#_iterm2_folder_paths}; i++)); do
            if [[ "$resolved" == "${_iterm2_folder_paths[$i]}"/* ]]; then
                colors=(${=_iterm2_folder_colors[$i]})
                _iterm2_set_tab_color ${colors[1]} ${colors[2]} ${colors[3]}
                return
            fi
        done
    fi
    if [[ ${#_iterm2_cmd_patterns} -gt 0 ]]; then
        for ((i = 1; i <= ${#_iterm2_cmd_patterns}; i++)); do
            if [[ "$cmd" =~ "${_iterm2_cmd_patterns[$i]}" ]]; then
                colors=(${=_iterm2_cmd_colors[$i]})
                _iterm2_set_tab_color ${colors[1]} ${colors[2]} ${colors[3]}
                return
            fi
        done
    fi
}

autoload -U add-zsh-hook
add-zsh-hook precmd  iterm2_tab_precmd
add-zsh-hook preexec iterm2_tab_preexec
