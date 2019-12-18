# bash-dirstack -  A simple implementation of a directory stack for bash.
#
#    Copyright (C) 2019 by Goetz Pfeiffer <goetzpf@googlemail.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.


# -------------------------------------------------------
#                      path stack
# -------------------------------------------------------

_BASH_DIRSTACK_DIR="$HOME/DIRSTACK"

# dir stack data file:
_BASH_DIRSTACK="$_BASH_DIRSTACK_DIR/default"

# last directory before change:
_BASH_DIRSTACK_LAST="$HOME"

# last directory before dsback command:
_BASH_DIRSTACK_LAST_BEF="$HOME"

if [ ! -d "$_BASH_DIRSTACK_DIR" ]; then
    if [ -e "$_BASH_DIRSTACK_DIR" ]; then
        echo "error: cannot create directory $_BASH_DIRSTACK_DIR"
        echo "since a file with this name exists."
        echo "You have to delete that file first."
    else
        mkdir -p "$_BASH_DIRSTACK_DIR"
    fi
fi

if [ ! -e $_BASH_DIRSTACK ]; then
    echo $HOME > "$_BASH_DIRSTACK"
fi

function dslist {
    if [ -z "$1" ]; then
        echo $_BASH_DIRSTACK:;nl $_BASH_DIRSTACK
    else
        nl $_BASH_DIRSTACK | grep -E -- "$1" 
    fi
}

alias dsp='dscdpush'
alias dspush='dscdpush'

function dscdpush {
    if [ -z "$1" ]; then
        pwd >> $_BASH_DIRSTACK
        return 0
    fi
    if [ ! -d "$1" ]; then
        echo "error, $1 is not a directory" >&2
        return 1
    fi
    _BASH_DIRSTACK_LAST=$(pwd)
    cd "$1" && pwd >> $_BASH_DIRSTACK
}

function dspushcd {
    if [ -z "$1" ]; then
        echo "error, directory missing" >&2
        return 1
    fi
    if [ ! -d "$1" ]; then
        echo "error, $1 is not a directory" >&2
        return 1
    fi
    pwd >> $_BASH_DIRSTACK
    _BASH_DIRSTACK_LAST=$(pwd)
    cd "$1"
}


function dsput {
    if [ ! -d "$1" ]; then
        echo "error, $1 is not a directory" >&2
        return 1
    fi
    (cd "$1" && pwd >> $_BASH_DIRSTACK)
}

function dspop {
    _BASH_DIRSTACK_LAST=$(pwd)
    cd "$(tail -n 1 $_BASH_DIRSTACK)"
    sed -i "$ d" $_BASH_DIRSTACK
}

function dsdropgo {
    sed -i "$ d" $_BASH_DIRSTACK
    _BASH_DIRSTACK_LAST=$(pwd)
    cd "$(tail -n 1 $_BASH_DIRSTACK)"
}

alias dsdrop='sed -i "$ d" $_BASH_DIRSTACK'

function dsngo {
    if [ -z "$1" ]; then
        _BASH_DIRSTACK_LAST=$(pwd)
        cd $(sed "\$!d" $_BASH_DIRSTACK)
    else
        if [[ ! "$1" =~ ^[0-9]+$ ]]; then 
            echo "error: argument must be an integer" >&2
            return 1
        fi
        if (( $1<1 )); then
            echo "integer must be greater or equal to 1" >&2
            return 1
        fi
        if (( $1>$(wc -l < $_BASH_DIRSTACK) )); then
            echo "integer is too large" >&2
            return 1
        fi
        _BASH_DIRSTACK_LAST=$(pwd)
        cd $(sed "${1}q;d" $_BASH_DIRSTACK)
    fi
}

function dsgo {
    if [ -z "$1" ]; then
        _BASH_DIRSTACK_LAST=$(pwd)
        cd $(sed "\$!d" $_BASH_DIRSTACK)
        return 0
    fi
    _BASH_DIRSTACK_MATCHES=$(grep -E -c -- "$1" $_BASH_DIRSTACK)
    if (( 0==$_BASH_DIRSTACK_MATCHES )); then
        echo "no match" >&2
        return 1
    fi
    _BASH_DIRSTACK_EXACT_MATCHES=$(grep -E -c -- "$1\$" $_BASH_DIRSTACK)
    if [ "$_BASH_DIRSTACK_EXACT_MATCHES" == "1" ]; then
        _BASH_DIRSTACK_LAST=$(pwd)
        cd $(grep -E -- "$1\$" $_BASH_DIRSTACK)
        return 0
    fi
    if [ -z "$2" ]; then
        if (( $_BASH_DIRSTACK_MATCHES == 1 )); then
            _BASH_DIRSTACK_LAST=$(pwd)
            cd $(grep -E -- "$1" $_BASH_DIRSTACK)
        else
            grep -E -- "$1" $_BASH_DIRSTACK | nl
        fi
    else
        if [[ ! "$2" =~ ^[0-9]+$ ]]; then 
            echo "error: 2nd argument must be an integer" >&2
            return 1
        fi
        if (( $2<1 )); then
            echo "integer must be greater or equal to 1" >&2
            return 1
        fi
        if (( $2 > $_BASH_DIRSTACK_MATCHES )); then
            echo "integer is too large" >&2
            return 1
        fi
        _BASH_DIRSTACK_LAST=$(pwd)
        cd $(grep -E -- "$1" $_BASH_DIRSTACK | sed "${2}q;d")
    fi
}

function dsback {
    _BASH_DIRSTACK_LAST_BEF="$_BASH_DIRSTACK_LAST"
    _BASH_DIRSTACK_LAST=$(pwd)
    cd $_BASH_DIRSTACK_LAST_BEF
}

alias dsedit='$EDITOR $_BASH_DIRSTACK'
alias dsclear='echo $HOME > $_BASH_DIRSTACK'

function dsset {
    if [ -z "$1" ]; then
        _BASH_DIRSTACK="$_BASH_DIRSTACK_DIR/default"
    else
        _BASH_DIRSTACK="$_BASH_DIRSTACK_DIR/$1"
    fi
    if [ ! -e "$_BASH_DIRSTACK" ]; then
        echo $HOME > "$_BASH_DIRSTACK"
    fi
}

function dssetlist {
    ls $_BASH_DIRSTACK_DIR
}

_BASH_DIRSTACK_COMMAND_ARRAY=(  \
    dsback \
    dscdpush \
    dsclear \
    dsdrop \
    dsdropgo \
    dsedit \
    dsgo \
    dshelp \
    dslist \
    dsngo \
    dspop \
    dsp \
    dspush \
    dspushcd \
    dsput \
    dsset \
    dssetlist \
)

_BASH_DIRSTACK_COMMANDS="${_BASH_DIRSTACK_COMMAND_ARRAY[@]}"

function dshelp { 
    local rx
    if [ -z "$1" ]; then 
        echo "Help for bash-dirstack"
        echo "Usage:"
        echo "dshelp TOPIC where topic is one of:"
        echo "  all     : Help for all commands"
        echo "  list    : List all known commands"
        echo "  COMMAND : help for a specific command"
        return
    else
        rx="\\b$1\\b"
        if [[ ! "all list $_BASH_DIRSTACK_COMMANDS" =~ $rx ]]; then
            echo "unkown command or TOPIC"
            echo "TOPIC must be 'all', 'list' or a known command"
            return
        fi
    fi
    if [ "$1" == "list" ]; then 
        echo "Help for bash-dirstack"
        echo "Known commands:"
        echo "$_BASH_DIRSTACK_COMMANDS" | fold -w 60 -s | column -t
        return
    fi
    if [ "$1" == "all" ]; then 
        echo '----------------------------------------------------------------------------'
        echo 'bash-dirstack 2.0.2'  
        echo '----------------------------------------------------------------------------'
        echo 'commands:'
        echo ''
    fi
    if [ "$1" == "all" -o "$1" == "dshelp" ]; then
        echo 'dshelp TOPIC          : Print help. '
        echo '                        When TOPIC is "all", print complete help, when TOPIC '
        echo '                        is "list", list all known commands. When TOPIC is neither'
        echo '                        "all" nor "list", interpret it as a name of a command and'
        echo '                        display help for that command.'
    fi
    if [ "$1" == "all" -o "$1" == "dslist" ]; then
        echo 'dslist [REGEXP]       : Show directory stack with line numbers. The stack is'
        echo '                        shown from bottom (first line) to top (last line). If'
        echo '                        REGEXP is given, show a list with line numbers of'
        echo '                        matching directories in the directory stack. For REGEXP'
        echo '                        see "man egrep".'
    fi
    if [ "$1" == "all" -o "$1" == "dsp" ]; then
        echo 'dsp [DIR]             : An alias for dscdpush.'
    fi
    if [ "$1" == "all" -o "$1" == "dspush" ]; then
        echo 'dspush [DIR]          : An alias for dscdpush.'
    fi
    if [ "$1" == "all" -o "$1" == "dscdpush" ]; then
        echo 'dscdpush [DIR]        : If DIR is given, go to DIR and put it on the top of the'
        echo '                        directory stack. If DIR is not given, push the current'
        echo '                        working directory on top of directory stack.'
    fi
    if [ "$1" == "all" -o "$1" == "dspushcd" ]; then
        echo 'dspushcd DIR          : Put the current working directory on the stack and'
        echo '                        change to DIR.'
    fi
    if [ "$1" == "all" -o "$1" == "dsput" ]; then
        echo 'dsput DIR             : Put directory DIR on top of the directory stack but do'
        echo '                        not change the current working directory.'
    fi
    if [ "$1" == "all" -o "$1" == "dspop" ]; then
        echo 'dspop                 : Remove top of the directory stack and go to that'
        echo '                        directory.'
    fi
    if [ "$1" == "all" -o "$1" == "dsdropgo" ]; then
        echo 'dsdropgo              : Remove top of the directory stack and go to the'
        echo '                        directory that is now the top of the stack.'
    fi
    if [ "$1" == "all" -o "$1" == "dsdrop" ]; then
        echo 'dsdrop                : Remove top of the directory stack but do not change the'
        echo '                        current working directory.'
    fi
    if [ "$1" == "all" -o "$1" == "dsngo" ]; then
        echo 'dsngo [NUMBER]        : Go to directory in line NUMBER in the directory stack.'
        echo '                        The line numbers can be seen with dslist. If NUMBER is'
        echo '                        omitted, go to the directory that is the top of the'
        echo '                        stack (the last one dslist shows).'
    fi
    if [ "$1" == "all" -o "$1" == "dsgo" ]; then
        echo 'dsgo [REGEXP] [NUMBER]: Go to match NUMBER in the list of directories from the'
        echo '                        stack that match regular expression REGEXP. For REGEXP'
        echo '                        see "man egrep". If NUMBER is missing and there is only'
        echo '                        one match or if the pattern matches a line go to that'
        echo '                        directory. If NUMBER is missing and there is more than'
        echo '                        one match, list all matches with line numbers.'
        echo '                        IF REGEXP and NUMBER are missing, go to the directory '
        echo '                        that is the top of the stack (the last one dslist '
        echo '                        shows).'
    fi
    if [ "$1" == "all" -o "$1" == "dsback" ]; then
        echo 'dsback                : Go back to that last directory before it was changed by'
        echo '                        a bash-dirstack command.'
    fi
    if [ "$1" == "all" -o "$1" == "dsedit" ]; then
        echo 'dsedit                : Edit directory stack file.'
    fi
    if [ "$1" == "all" -o "$1" == "dsclear" ]; then
        echo 'dsclear               : Initialize the directory stack with a single entry,'
        echo '                        which is your home directory.'
    fi
    if [ "$1" == "all" -o "$1" == "dsset" ]; then
        echo 'dsset [TAG]           : Initialize or use new directory stack file with tag.'
        echo '                        TAG. If TAG is not given use the standard filename.'
    fi
    if [ "$1" == "all" -o "$1" == "dssetlist" ]; then
        echo 'dssetlist             : List existing tags for dsset command.'
    fi
    if [ "$1" == "all" ]; then
        echo ''
        echo '----------------------------------------------------------------------------'
    fi
  }    

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

function x {
    echo "${_BASH_DIRSTACK_COMMANDS[@]}"
}
C="${_BASH_DIRSTACK_COMMANDS[@]}"

complete -F _dsngo_completions dsngo 
complete -F _dsgo_completions dsgo 
complete -F _dsgo_completions dslist
complete -W "all list $_BASH_DIRSTACK_COMMANDS" dshelp
complete -W "" dspop
complete -W "" dsdropgo
complete -W "" dsdrop
complete -W "" dsedit
complete -W "" dsclear
complete -W "" dsback
complete -d dscdpush
complete -d dsp
complete -d dspush
complete -d dspushcd
complete -d dsput
complete -W "" dssetlist
complete -F _dsset_completions dsset
