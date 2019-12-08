#/usr/bin/env bash

# bash completions for bash-dirstack functions.

function _dsngo_completions {
    local line
    local i
    local IFS
    if (( $COMP_CWORD > 1 )); then
      return
    fi
    arg="${COMP_WORDS[$COMP_CWORD]}"
    i=0
    IFS=$'\n'
    for line in $(nl $_BASH_DIRSTACK | grep "^ *$arg" | sed -e 's/\t/ /g'); do
        # extra long lines in order to have one completion suggestion per
        # line:
        COMPREPLY[$i]=$(printf "%*s\n" -$COLUMNS $line)
        ((i++))
    done
    COMPREPLY[$i]=""
    IFS=
}

function _dsgo_completions {
    local arg
    local n
    local IFS
    if (( $COMP_CWORD > 1 )); then
      return
    fi
    arg="${COMP_WORDS[$COMP_CWORD]}"
    if [ -z "$arg" ]; then
        IFS=$'\n'
        COMPREPLY=( $(cat $_BASH_DIRSTACK) )
        IFS=
        return
    fi
    n=$(grep -E -c -- "$arg" $_BASH_DIRSTACK)
    if [ "$n" = 0 ]; then
        IFS=$'\n'
        COMPREPLY=( $(cat $_BASH_DIRSTACK) )
        IFS=
        return
    fi
    IFS=$'\n'
    COMPREPLY=( $(grep -E -- "$arg" $_BASH_DIRSTACK) )
    IFS=
}

function _dsset_completions {
    local IFS
    local arg
    if (( $COMP_CWORD > 1 )); then
      return
    fi
    arg="${COMP_WORDS[$COMP_CWORD]}"
    IFS=$'\n'
    if [ -z "$arg" ]; then
        COMPREPLY=( $(ls -1 $_BASH_DIRSTACK_DIR) )
    else
        COMPREPLY=( $(ls -1 $_BASH_DIRSTACK_DIR | grep "^$arg") )
    fi
    IFS=
}

complete -F _dsngo_completions dsngo 
complete -F _dsgo_completions dsgo 
complete -F _dsgo_completions dslist
complete -W "" dshelp
complete -W "" dspop
complete -W "" dsdropgo
complete -W "" dsdrop
complete -W "" dsedit
complete -W "" dsclear
complete -W "" dsback
complete -d dscdpush
complete -d dspush
complete -d dspushcd
complete -d dsput
complete -W "" dssetlist
complete -F _dsset_completions dsset
