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

alias PUSH='pwd >> $MY_PATHSTACK'
alias POP='cd "$(tail -n 1 $MY_PATHSTACK)"; sed -i "$ d" $MY_PATHSTACK'
alias PLIST='echo $MY_PATHSTACK:;nl $MY_PATHSTACK'
alias PEDIT='$EDITOR $MY_PATHSTACK'
alias PCLEAR='echo $HOME > $MY_PATHSTACK'
alias PSET-LIST='ls $HOME/PATH.* 2>/dev/null | sed -e "s/^.*PATH\.//"'

function PSET {
    if [ -z "$1" ]; then
        MY_PATHSTACK="$HOME/PATH"
    else
        MY_PATHSTACK="$HOME/PATH.$1"
    fi
    if [ ! -e "$MY_PATHSTACK" ]; then
        echo $HOME > "$MY_PATHSTACK"
    fi
}

function PGO {
    if [ -z "$1" ]; then
        cd $(sed "\$!d" $MY_PATHSTACK)
    else
        cd $(sed "${1}q;d" $MY_PATHSTACK)
    fi

function PHELP
  { 
    echo '----------------------------------------------------------------------------'
    echo 'extra commands for the directory stack:'
    echo 'PUSH                    : push directory on directory stack'
    echo 'POP                     : pop directory from directory stack and change directory'
    echo 'PLIST                   : show directory stack with line numbers'
    echo 'PEDIT                   : edit directory stack file'
    echo 'PCLEAR                  : set directory stack to one entry: \$HOME'
    echo 'PGO NUMBER              : go to directory NUMBER'
    echo 'PSET [TAG]              : create/use new directory stack file with tag TAG. If TAG is'
    echo '                          not given use the standard filename.'
    echo 'PSET-LIST               : list existing tags for PSET command'
    echo
    echo '----------------------------------------------------------------------------'
  }    

# path stack data file:
MY_PATHSTACK="$HOME/PATH"

