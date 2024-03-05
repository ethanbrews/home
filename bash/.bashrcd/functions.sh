# _can_exec $1: Test if a program, $1, is installed and in $PATH
function _can_exec {
  builtin type -P "$1" &> /dev/null
}

# optalias $1, $2, $3: Create an alias, $2=$3 if $1 is found in $PATH
function optalias() {
    local executable=${1}
    local alias=${2}
    local value=${3}

    if _can_exec $executable; then
        alias $alias="$value"
    fi
}

# optalias $1, $2: Create an alias, $1, to a python script, $2, if it exists
function pyalias() {
    local alias=${1}
    local script=${2}
    
    if _can_exec python3 $$ [ -f $script ]; then
        alias $alias='python3 "$script"'
    fi
}

function trysource() {
    if [ -f "$1" ]; then
        source "$1"
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
    ls --color=auto
    return $EXIT
}

# _zl $1: cd to $1 then ls. If $1 is a file, then go to containing folder. If 2+ arguments are provided, use zoxide.
function _zl {
	# Normal cd behaviour with 0 or 1 args
	if [ "$#" -eq 0 ]; then	
		eval "z"
		EXIT=$?
	elif [ "$#" -eq 1 ]; then
		if [ -d "$1" ] || [ "$1" == "-" ]; then
			eval "z '$1'"
			EXIT=$?
		elif [ -f "$1" ]; then
                        DIRNAME=$(dirname "$1")
                        eval "\cd '$DIRNAME'"
                        EXIT=$?
		else
			echo "_zl: $1: No such file or directory"
			EXIT=1
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

	ls --color=auto
	return #EXIT
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
            CD=$(eval "printf '../%.0s' {1..$1}")
            echo "$CD"
            eval "cd $CD"
        fi
    fi
}

# _h2d $1: Read $1 in hexadecimal form and print in decimal form
function _h2d(){
	printf "%d\n" $1
}

# _d2h $1: Read $1 in decimal form and print in hexadecimal form
function _d2h(){
	printf "%x\n" $1
}

# _show_info $1: Show basic info about the file or directory, $1
function _show_info {
	FILESIZE=$(stat -c%s "$1" | numfmt --to=iec)
	FILETYPE=$(stat -c%F "$1")
	FILENAME=$(stat -c%n "$1")

	echo "$FILESIZE $FILENAME ($FILETYPE)"
}
