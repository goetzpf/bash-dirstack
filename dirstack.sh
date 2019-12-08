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

_BASH_DIRSTACK_FILENAME="$HOME/DIRSTACK"

# path stack data file:
_BASH_DIRSTACK="$_BASH_DIRSTACK_FILENAME"

# last directory before change:
_BASH_DIRSTACK_LAST="$HOME"

# last directory before PBACK command:
_BASH_DIRSTACK_LAST_BEF="$HOME"

if [ ! -e $_BASH_DIRSTACK ]; then
    echo $HOME > "$_BASH_DIRSTACK"
fi

function PLIST {
    if [ -z "$1" ]; then
        echo $_BASH_DIRSTACK:;nl $_BASH_DIRSTACK
    else
        nl $_BASH_DIRSTACK | grep -E -- "$1" 
    fi
}

function PUSH {
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

function PPUSH {
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


function PUT {
    if [ ! -d "$1" ]; then
        echo "error, $1 is not a directory" >&2
        return 1
    fi
    (cd "$1" && pwd >> $_BASH_DIRSTACK)
}

function POP {
    _BASH_DIRSTACK_LAST=$(pwd)
    cd "$(tail -n 1 $_BASH_DIRSTACK)"
    sed -i "$ d" $_BASH_DIRSTACK
}

function PPOP {
    sed -i "$ d" $_BASH_DIRSTACK
    _BASH_DIRSTACK_LAST=$(pwd)
    cd "$(tail -n 1 $_BASH_DIRSTACK)"
}

alias PDROP='sed -i "$ d" $_BASH_DIRSTACK'

function PGO {
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

function PXGO {
    if [ -z "$1" ]; then
        echo "REGEXP missing" >&2
        return 1
    fi
    _BASH_DIRSTACK_MATCHES=$(grep -E -c -- "$1" $_BASH_DIRSTACK)
    if (( 0==$_BASH_DIRSTACK_MATCHES )); then
        echo "no match" >&2
        return 1
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

function PBACK {
    _BASH_DIRSTACK_LAST_BEF="$_BASH_DIRSTACK_LAST"
    _BASH_DIRSTACK_LAST=$(pwd)
    cd $_BASH_DIRSTACK_LAST_BEF
}

alias PEDIT='$EDITOR $_BASH_DIRSTACK'
alias PCLEAR='echo $HOME > $_BASH_DIRSTACK'

function PSET {
    if [ -z "$1" ]; then
        _BASH_DIRSTACK="$_BASH_DIRSTACK_FILENAME"
    else
        _BASH_DIRSTACK="$_BASH_DIRSTACK_FILENAME.$1"
    fi
    if [ ! -e "$_BASH_DIRSTACK" ]; then
        echo $HOME > "$_BASH_DIRSTACK"
    fi
}

alias PSET-LIST='ls $_BASH_DIRSTACK_FILENAME.* 2>/dev/null | sed -e "s#$_BASH_DIRSTACK_FILENAME\.##"'

function PHELP
  { 
    echo '----------------------------------------------------------------------------'
    echo 'bash-dirstack 1.0.1'
    echo '----------------------------------------------------------------------------'
    echo 'commands:'
    echo  
    echo 'PLIST [REGEXP]        : Show directory stack with line numbers. The stack is'
    echo '                        shown from bottom (first line) to top (last line).  If'
    echo '                        REGEXP is given, show a list with line numbers of'
    echo '                        matching directories in the directory stack. For REGEXP'
    echo '                        see "man egrep".'
    echo 'PUSH [DIR]            : If DIR is given, go to DIR and put it on the top of the'
    echo '                        directory stack. If DIR is not given, push the current'
    echo '                        working directory on top of directory stack.'
    echo 'PPUSH DIR             : Put the current working directory on the stack and'
    echo '                        change to DIR.'
    echo 'PUT [DIR]             : Put directory DIR on top of the directory stack but do'
    echo '                        not change the current working directory.'
    echo 'POP                   : Remove top of the directory stack and go to that'
    echo '                        directory.'
    echo 'PPOP                  : Remove top of the directory stack and go to the'
    echo '                        directory that is now the top of the stack.'
    echo 'PDROP                 : Remove top of the directory stack but do not change the'
    echo '                        current working directory.'
    echo 'PGO [NUMBER]          : Go to directory in line NUMBER in the directory stack.'
    echo '                        The line numbers can be seen with PLIST. If NUMBER is'
    echo '                        omitted, go to the directory that is the top of the'
    echo '                        stack (the last one PLIST shows).'
    echo 'PXGO REGEXP [NUMBER]  : Go to match NUMBER in the list of directories from the'
    echo '                        stack that match regular expression REGEXP. For REGEXP'
    echo '                        see "man egrep".  If NUMBER is missing and there is'
    echo '                        only one match, go to that directory.  If NUMBER is'
    echo '                        missing and there is more than one match, list all'
    echo '                        matches with line numbers.'
    echo 'PBACK                 : Go back to that last directory before it was changed by'
    echo '                        a bash-dirstack command.'
    echo 'PEDIT                 : Edit directory stack file.'
    echo 'PCLEAR                : Initialize the directory stack with a single entry,'
    echo '                        which is your home directory.'
    echo 'PSET [TAG]            : Initialize or use new directory stack file with tag.'
    echo '                        TAG. If TAG is not given use the standard filename.'
    echo 'PSET-LIST             : List existing tags for PSET command.'
    echo
    echo '----------------------------------------------------------------------------'
  }    

