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
    ls
    return $EXIT
}

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

	ls
	return #EXIT
}

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

# File extractor
# usage: extract <file>
function _extract {
	python3 $HOME/.bashrcd/extract.py "$@"
}

_h2d(){
	printf "%d\n" $1
}
_d2h(){
	printf "%x\n" $1
}

function _show_info {
	FILESIZE=$(stat -c%s "$1" | numfmt --to=iec)
	FILETYPE=$(stat -c%F "$1")
	FILENAME=$(stat -c%n "$1")

	echo "$FILESIZE $FILENAME ($FILETYPE)"
}
