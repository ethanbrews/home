export PROMPT_COMMAND=__prompt_command # Func to gen PS1 after CMDs

__prompt_command() {
    local EXIT="$?"             # This needs to be first
    PS1=""

    local ColorOff="\[\033[0m\]" # Text Reset

    local RGreen="\[\033[0;32m\]"   # Green - Regular
    local RYellow="\[\033[0;33m\]"  # Yellow
    local RBlue="\[\033[0;34m\]"    # Blue

    local BRed="\[\033[1;31m\]"     # Red - Bold
    local BGreen="\[\033[1;32m\]"   # Green
    local BBlue="\[\033[1;34m\]"    # Blue

    if [ $EXIT != 0 ] ; then
        PS1+="${BRed}${EXIT}${ColorOff}|"      # Add red if exit code non 0
    fi

    if [ -n "$VIRTUAL_ENV" ] ; then
        PS1+="(venv)|"
    fi

    if [ $EUID == 0 ] ; then
        PS1+="${BRed}^${ColorOff}"
    else
        PS1+="${BGreen}[${ColorOff}"
    fi

    PS1+="$(date +'%H:%M:%S') ${RGreen}\w${ColorOff}"

    GIT_BRANCH=$(git branch 2>/dev/null | awk '/^\*/ {print $2}' 2>/dev/null)
    if [ -n "$GIT_BRANCH" ] ; then
        PS1+=" ${RYellow}(${GIT_BRANCH})${ColorOff}"
    fi

    if [ $EUID == 0 ] ; then
        PS1+="${BRed}^${ColorOff}# "
    else
        PS1+="${BGreen}]${ColorOff}$ "
    fi
}
