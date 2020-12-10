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

_BASH_DIRSTACK_VERSION="3.1.1"

_BASH_DIRSTACK_DIR="$HOME/DIRSTACK"

_BASH_DIRSTACK_CONFIG="$_BASH_DIRSTACK_DIR/CONFIG"

# last directory before change:
_BASH_DIRSTACK_LAST="$HOME"

# last directory before dsback command:
_BASH_DIRSTACK_LAST_BEF="$HOME"

if [ ! -d "$_BASH_DIRSTACK_DIR" ]; then
    if [ -e "$_BASH_DIRSTACK_DIR" ]; then
        echo "error: cannot create directory $_BASH_DIRSTACK_DIR"
        echo "since a file with this name exists."
        echo "You have to delete that file first."
        exit 0
    else
        mkdir -p "$_BASH_DIRSTACK_DIR"
    fi
fi

if [ ! -e $_BASH_DIRSTACK_CONFIG ]; then
    # create config file if it doesn't exist,
    # use "default" as the default dir stack data file:
    echo "_BASH_DIRSTACK=$_BASH_DIRSTACK_DIR/default" > "$_BASH_DIRSTACK_CONFIG"
fi

# This sets the _BASH_DIRSTACK variable:
. "$_BASH_DIRSTACK_CONFIG"

# Create dir stack data file if it doesn't exist:
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

function dsPush {
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

alias dsp="dspush"

function dspush {
    if [ -z "$1" ]; then
        pwd >> $_BASH_DIRSTACK
        return 0
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

function dsPop {
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
            echo "re-run the command and add a line number:"
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

function dssort {
    # LC_COLLATE must be set to "C" in order for sort
    # not to ignore non-alphanumeric characters:
    LC_COLLATE=C sort -u $_BASH_DIRSTACK > $_BASH_DIRSTACK_DIR/TMP
    cp -a $_BASH_DIRSTACK_DIR/TMP $_BASH_DIRSTACK
}

function dsset {
    if [ -z "$1" ]; then
        echo "Current directory stack: $(basename $_BASH_DIRSTACK)"
        return
    fi
    if [ ! -e "$_BASH_DIRSTACK_DIR/$1" ]; then
        echo "Directory stack $1 doesn't exist yet."
        if [ $(basename $(echo $SHELL)) == "bash" ]; then
            read -p "Create it ? (Y/N) " -n 1 -r
            echo 
        else
            # Note: since 'read' works differently in the z-shell we do a
            # "read" here by calling bash with the read command in it's command
            # argument.  Although z-shell is not officially supported by
            # bash-dirstack it actually works for the z-shell, too.
            REPLY=$(bash -c 'read -p "Create it ? (Y/N) " -n 1; echo $REPLY')
            echo 
        fi
        if [ "$REPLY" = "Y" -o "$REPLY" = "y" ]; then
            echo "Directory stack $1 is created."
        else
            echo "Aborted"
            return
        fi
    fi
    _BASH_DIRSTACK="$_BASH_DIRSTACK_DIR/$1"
    if [ ! -e "$_BASH_DIRSTACK" ]; then
        echo $HOME > "$_BASH_DIRSTACK"
    fi
    # remember this in the CONFIG file:
    sed -i "$_BASH_DIRSTACK_CONFIG" -e "s;^\(_BASH_DIRSTACK=\).*;\1$_BASH_DIRSTACK;"
}

function dssetlist {
    ls $_BASH_DIRSTACK_DIR
}

_BASH_DIRSTACK_COMMAND_ARRAY=(  \
    dsback \
    dsclear \
    dsdrop \
    dsedit \
    dsgo \
    dshelp \
    dslist \
    dsngo \
    dsp \
    dspop \
    dsPop \
    dspush \
    dsPush \
    dsput \
    dsset \
    dssetlist \
    dssort \
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
        if [[ ! "all all-raw list $_BASH_DIRSTACK_COMMANDS" =~ $rx ]]; then
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
        # if the "less" is present, use it:
        if less -V >/dev/null 2>&1; then
            dshelp all-raw | less
            return
        else
            # set $1 to "all-raw":
            set -- "all-raw"
        fi
    fi
    if [ "$1" == "all-raw" ]; then 
        echo '----------------------------------------------------------------------------'
        echo "bash-dirstack $_BASH_DIRSTACK_VERSION"
        echo '----------------------------------------------------------------------------'
        echo ''
    fi
    if [ "$1" == "all-raw" ]; then 
        echo 'help:'
        echo ''
    fi
    if [ "$1" == "all-raw" -o "$1" == "dshelp" ]; then
        echo '    dshelp TOPIC          : Print help.'
        echo '                            When TOPIC is "all", print complete help, when'
        echo '                            TOPIC is "list", list all known commands. When'
        echo '                            TOPIC is neither "all" nor "list", interpret it as'
        echo '                            a name of a command and display help for that'
        echo '                            command.'
    fi
    if [ "$1" == "all-raw" ]; then 
        echo ''
        echo 'Push/Pop *without* current working dir on the stack:'
        echo ''
    fi
    if [ "$1" == "all-raw" -o "$1" == "dsp" ]; then
        echo '    dsp [DIR]             : An alias for dspush.'
    fi
    if [ "$1" == "all-raw" -o "$1" == "dspush" ]; then
        echo '    dspush [DIR]          : Put the current working directory on the top of the'
        echo '                            directory stack. Then, if DIR is given, go to'
        echo '                            directory DIR.'
    fi
    if [ "$1" == "all-raw" -o "$1" == "dspop" ]; then
        echo '    dspop                 : Remove top of the directory stack and go to that'
        echo '                            directory.'
    fi
    if [ "$1" == "all-raw" ]; then 
        echo ''
        echo 'Push/Pop *with* current working dir on the stack:'
        echo ''
    fi
    if [ "$1" == "all-raw" -o "$1" == "dsPop" ]; then
        echo '    dsPop                 : Remove top of the directory stack and go to the'
        echo '                            directory that is now the top of the stack.'
    fi
    if [ "$1" == "all-raw" -o "$1" == "dsPush" ]; then
        echo '    dsPush [DIR]          : If DIR is given, go to DIR and put it on the top of'
        echo '                            the directory stack. If DIR is not given, push the'
        echo '                            current working directory on top of directory'
        echo '                            stack.'
    fi
    if [ "$1" == "all-raw" ]; then 
        echo ''
        echo 'Go to arbitrary dir from the stack:'
        echo ''
    fi
    if [ "$1" == "all-raw" -o "$1" == "dsngo" ]; then
        echo '    dsngo [NUMBER]        : Go to directory in line NUMBER in the directory'
        echo '                            stack. The line numbers can be seen with dslist. If'
        echo '                            NUMBER is omitted, go to the directory that is the'
        echo '                            top of the stack (the last one dslist shows).'
    fi
    if [ "$1" == "all-raw" -o "$1" == "dsgo" ]; then
        echo '    dsgo [REGEXP] [NUMBER]: Go to match NUMBER in the list of directories from'
        echo '                            the stack that match regular expression REGEXP. For'
        echo '                            REGEXP see "man egrep".  If NUMBER is missing and'
        echo '                            there is only one match or if the pattern matches a'
        echo '                            line go to that directory. If NUMBER is missing and'
        echo '                            there is more than one match, list all matches with'
        echo '                            line numbers.  IF REGEXP and NUMBER are missing, go'
        echo '                            to the directory that is the top of the stack (the'
        echo '                            last one dslist shows).'
    fi
    if [ "$1" == "all-raw" ]; then 
        echo ''
        echo 'Query the directory stack:'
        echo ''
    fi
    if [ "$1" == "all-raw" -o "$1" == "dslist" ]; then
        echo '    dslist [REGEXP]       : Show directory stack with line numbers. The stack'
        echo '                            is shown from bottom (first line) to top (last'
        echo '                            line). If REGEXP is given, show a list with line'
        echo '                            numbers of matching directories in the directory'
        echo '                            stack. For REGEXP see "man egrep".'
    fi
    if [ "$1" == "all-raw" ]; then 
        echo ''
        echo 'Modify the directory stack:'
        echo ''
    fi
    if [ "$1" == "all-raw" -o "$1" == "dsput" ]; then
        echo '    dsput DIR             : Put directory DIR on top of the directory stack but'
        echo '                            do not change the current working directory.'
    fi
    if [ "$1" == "all-raw" -o "$1" == "dsdrop" ]; then
        echo '    dsdrop                : Remove top of the directory stack but do not change'
        echo '                            the current working directory.'
    fi
    if [ "$1" == "all-raw" -o "$1" == "dsedit" ]; then
        echo '    dsedit                : Edit directory stack file.'
    fi
    if [ "$1" == "all-raw" -o "$1" == "dsclear" ]; then
        echo '    dsclear               : Initialize the directory stack with a single entry,'
        echo '                            which is your home directory.'
    fi
    if [ "$1" == "all-raw" -o "$1" == "dssort" ]; then
        echo '    dssort                : Apply "sort -u" to the directory stack file. This means'
        echo '                            that all entries are sorted and unique. Note that there'
        echo '                            is no undo command for this.'
    fi
    if [ "$1" == "all-raw" ]; then 
        echo ''
        echo 'Manage more than one directory stack:'
        echo ''
    fi
    if [ "$1" == "all-raw" -o "$1" == "dsset" ]; then
        echo '    dsset [TAG]           : Initialize or use new directory stack file with tag TAG.'
        echo '                            If TAG is not given show thw current directory stack name.'
        echo '                            If the stack file does not yet exist, the program asks for'
        echo '                            confirmation. The TAG is remembered globally in file'
        echo '                            "CONFIG" as new default for the directory stack file.'
    fi
    if [ "$1" == "all-raw" -o "$1" == "dssetlist" ]; then
        echo '    dssetlist             : List existing tags for dsset command.'
    fi
    if [ "$1" == "all-raw" ]; then 
        echo ''
        echo 'Revert the last directory change:'
        echo ''
    fi
    if [ "$1" == "all-raw" -o "$1" == "dsback" ]; then
        echo '    dsback                : Go back to that last directory before it was'
        echo '                            changed by a bash-dirstack command.'
    fi
    if [ "$1" == "all-raw" ]; then
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
        COMPREPLY=( $(ls -1 $_BASH_DIRSTACK_DIR | grep -w -v CONFIG) )
    else
        COMPREPLY=( $(ls -1 $_BASH_DIRSTACK_DIR | grep -w -v CONFIG | grep "^$arg") )
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
complete -W "" dsPop
complete -W "" dsdrop
complete -W "" dsedit
complete -W "" dsclear
complete -W "" dssort
complete -W "" dsback
complete -d dsPush
complete -d dsp
complete -d dspush
complete -d dsput
complete -W "" dssetlist
complete -F _dsset_completions dsset
