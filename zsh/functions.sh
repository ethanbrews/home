# _can_exec $1: Test if a program, $1, is installed and in $PATH
function _can_exec {
  command -v "$1" &> /dev/null
}

# trypath $1: Add $1 to path if it exists
function _trypath() {
    if [ -d "$1" ]; then
        export PATH="$PATH:$1"
    fi
}

# optalias $1, $2, $3: Create an alias, $2=$3 if $1 is found in $PATH
function _optalias() {
    local executable=${1}
    local alias=${2}
    local value=${3}

    if _can_exec $executable; then
        alias $alias="$value"
    fi
}

# optalias $1, $2: Create an alias, $1, to a python script, $2, if it exists
function _pyalias() {
    local alias=${1}
    local script=${2}

    if _can_exec python3 && [ -f $script ]; then
        alias $alias="python3 '$script'"
    fi
}

function _trysource() {
    if [ -f "$1" ]; then
        source "$1"
    fi
}

# Print directory contents used in _cl, _zl
function _print_dir() {
    N_FILES=$(ls -l | wc -l)
    if [ "$N_FILES" -gt 200 ]; then
        echo -e "\e[34m$N_FILES\e[0m items in directory"
    else
	    ls --color=auto
    fi
}

# _cl $1: cd to $1 then ls. If $1 is a file, then go to containing folder.
function _cl {
    EXIT=0
    if [[ "$1" == "" ]]
    then
        eval "\cd"
        EXIT=$?
    else
        # $1 is-a:
        #   - directory, or
        #   - "-" (go back to previous folder)
        if [ -d "$1" ] || [ "$1" == "-" ]; then
            eval "\cd '$1'"
            EXIT=$?
        # $1 is-a:
        #   - file
        elif [ -f "$1" ]; then
            DIRNAME=$(dirname "$1")
            echo "$1 >>> ${DIRNAME}/"
            eval "\cd '$DIRNAME'"
            EXIT=$?
        # $1 not a valid value
        else
            echo "_cl: $1: No such file or directory"
            EXIT=1
        fi
    fi
    if [ -f .env.sh ] ; then
        # shellcheck disable=SC1091
        source .env.sh
    fi
    _print_dir
    return $EXIT
}

is_base64() {
    local input="$1"

    # Reject empty strings
    if [[ -z "$input" ]]; then
        return 1
    fi

    # Standard Base64 regex pattern matching:
    # 1. Length must be a multiple of 4
    # 2. Characters must be A-Z, a-z, 0-9, +, /
    # 3. Can end with valid '=' or '==' padding
    local b64_regex='^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$'

    if [[ "$input" =~ $b64_regex ]]; then
        return 0
    else
        return 1
    fi
}

# _zl $1: cd to $1 then ls. If $1 is a file, then go to containing folder. If 2+ arguments are provided, use zoxide.
function _zl {
    EXIT=0
	# Normal cd behaviour with 0 or 1 args
	if [ "$#" -eq 0 ]; then	
		eval "z"
		EXIT=$?
	elif [ "$#" -eq 1 ]; then
		if [ -f "$1" ]; then
			DIRNAME=$(dirname "$1")
            eval "\cd '$DIRNAME'"
            EXIT=$?	
		else
			eval "\cd $@"
			EXIT=$?
		fi
	else
		# Let z deal with 2+ args
		eval "z $@"
		EXIT=$?
	fi
	
    if [ -f .env.sh ] ; then
        # shellcheck disable=SC1091
        source .env.sh
	fi

    _print_dir

	return $EXIT
}

# _go_back $1=1: Go back $1 directories
function _go_back {
    if [[ "$1" == "" ]];then
        eval "cd .."
    else
        re='^[0-9]+$'
        if ! [[ $1 =~ $re ]] ; then
            echo "error: Not a valid number" >&2; return 1
        fi
        if [[ "$1" -gt "0" ]] ; then
            CD=""
            for ((i=1; i<=$1; i++)); do
                CD+="../"
            done
            echo "$CD"
            eval "cd $CD"
        fi
    fi
}

# _h2d $1: Read $1 in hexadecimal form and print in decimal form
function h2d(){
	printf "%d\n" $1
}

# _d2h $1: Read $1 in decimal form and print in hexadecimal form
function d2h(){
	printf "%x\n" $1
}

csview()
{
    local file="$1"
    cat "$file" | sed -e 's/,,/, ,/g' | column -s, -t | less -#5 -N -S
}

# _show_info $1: Show basic info about the file or directory, $1
function _show_info {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS stat syntax
        FILESIZE=$(stat -f%z "$1" | numfmt --to=iec 2>/dev/null || stat -f%z "$1")
        FILETYPE=$(stat -f%HT "$1")
        FILENAME=$(stat -f%N "$1")
        FILEPERM=$(stat -f%Sp "$1")
    else
        # GNU stat syntax (Linux)
        FILESIZE=$(stat -c%s "$1" | numfmt --to=iec)
        FILETYPE=$(stat -c%F "$1")
        FILENAME=$(stat -c%n "$1")
        FILEPERM=$(stat -c%A "$1")
    fi

    echo "$FILESIZE $FILENAME ($FILETYPE) [$FILEPERM]"
}

# Remove consecutive duplicate lines from the input
dedupe() {
 sed -E '
  $!{
   N;
   s/[ \t]+$//;
   /^(.*)\n\1$/!P;
   D;
  }
 ';
}

# Remove any duplicate lines from the input
norepeat() {
 sed -n -E '
  s/[ \t]+$//;
  G;
  /^(\n){2,}/d;
  /^([^\n]+).*\n\1(\n|$)/d;
  h;
  P;
  ';
}

function show_color_table {
    for x in {0..8}; do
        for i in {30..37}; do
            for a in {40..47}; do
                echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "
            done
            echo
        done
    done
    echo ""
}
alias show_colour_table=show_color_table

function _tm() {
    if [ "$#" -eq 0 ]; then
        N_SESSIONS=$(tmux list-sessions | wc -l)
        if [ "$N_SESSIONS" -eq 0 ]; then
            tmux new -s "main"
        elif [ "$N_SESSIONS" -eq 1 ]; then
            tmux attach-session
        else
            tmux attach-session -t $(tmux list-sessions | fzf | awk -F: '{print $1}')
        fi
    else
        tmux attach-session -t $1
    fi
}

function _open_zellij() {
    if [ "$#" -eq 0 ]; then
        N_SESSIONS=$(zellij list-sessions | wc -l)
        if [ "$N_SESSIONS" -eq 0 ]; then
            zellij -s "main"
        elif [ "$N_SESSIONS" -eq 1 ]; then
            zellij attach $(zellij list-sessions | sed -e 's/\x1b\[[0-9;]*m//g' -e 's/ .*$//')
        else
            zellij attach $(zellij list-sessions | sed -e 's/\x1b\[[0-9;]*m//g' -e 's/ - attach to resurrect//' | fzf | sed 's/ .*$//')
        fi
    else
        zellij attach $1
    fi
}

function _git_switch() {

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    print -P "%F{red}error:%f not a git repository."
    return 1
  fi

  local branch
  # Get local branches, excluding the current one for a cleaner list
  branch=$(git branch --format='%(refname:short)' | \
    fzf --height 40% \
        --layout=reverse \
        --border=none \
        --prompt="󱓞 Switch Branch: " \
        --pointer="▶" \
        --color="hl:-1:underline,hl+:-1:underline:bold" \
        --preview 'git log --oneline --graph --color=always -n 10 {}')

  if [[ -n "$branch" ]]; then
    git switch "$branch"
  fi
}

function _git_cleanup() {
  local dry_run=false
  [[ "$1" == "-n" || "$1" == "--dry-run" ]] && dry_run=true

  # Extract default branch
  local base=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
  : ${base:=$(git rev-parse --abbrev-ref HEAD)}

  # Guard: Ensure we are in a git repo
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1

  [[ "$dry_run" == "false" ]] && git checkout -q "$base"

  git for-each-ref refs/heads/ "--format=%(refname:short)" | while read -r branch; do
    [[ "$branch" == "$base" ]] && continue

    local merge_base=$(git merge-base "$base" "$branch")
    local commit_tree=$(git commit-tree "$branch^{tree}" -p "$merge_base" -m _)

    if [[ $(git cherry "$base" "$commit_tree") == "-"* ]]; then
      if [[ "$dry_run" == "true" ]]; then
        echo "$branch (merged)"
      else
        git branch -D "$branch"
      fi
    fi
  done
}

function git-restore-from() {
  if [[ -z "$1" ]]; then
    echo "Usage: git-restore-from <branch-name> [path...]" >&2
    return 1
  fi

  local branch="$1"
  shift
  git restore --source="$branch" --staged -- "${@:-.}"
}
