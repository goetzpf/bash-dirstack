=================
bash-dirstack 2.0
=================

An implementation of a persistent directory stack in bash.

Motivation
----------

Although bash has the built-in commands "dirs", "pushd" and "popd" that manage
a directory stack, these commands lack certain features.  

bash-dirstack has the following advantages:

- A single directory stack file can be shared across *all* terminal windows of
  your session.
- The directory stack is a text file than can be edited.
- The directory stack is preserved after you log off.
- You can use several directory stacks, each with a different name.
- You can go to the last entry on the stack without removing it from the stack.
- You can navigate to directories in the stack without changing the stack.
- You can use strings, even regular expressions to select directories from the stack.

How to install
--------------

Add all lines from file "dirstack.sh" to your file .bashrc or include them by
adding this line to .bashrc::

  source DIRECTORY/dirstack.sh

DIRECTORY is, of course, the directory where "dirstack.sh" can be found.

Usage
-----

These are the commands of bash-dirstack, each command starts with "ds"::

  dslist [REGEXP]       : Show directory stack with line numbers. The stack is
                          shown from bottom (first line) to top (last line). If
                          REGEXP is given, show a list with line numbers of
                          matching directories in the directory stack. For REGEXP
                          see "man egrep".
  dspush [DIR]          : An alias for dscdpush.
  dscdpush [DIR]        : If DIR is given, go to DIR and put it on the top of the
                          directory stack. If DIR is not given, push the current
                          working directory on top of directory stack.
  dspushcd DIR          : Put the current working directory on the stack and
                          change to DIR.
  dsput DIR             : Put directory DIR on top of the directory stack but do
                          not change the current working directory.
  dspop                 : Remove top of the directory stack and go to that
                          directory.
  dsdropgo              : Remove top of the directory stack and go to the
                          directory that is now the top of the stack.
  dsdrop                : Remove top of the directory stack but do not change the
                          current working directory.
  dsngo [NUMBER]        : Go to directory in line NUMBER in the directory stack.
                          The line numbers can be seen with dslist. If NUMBER is
                          omitted, go to the directory that is the top of the
                          stack (the last one dslist shows).
  dsgo [REGEXP] [NUMBER]: Go to match NUMBER in the list of directories from the
                          stack that match regular expression REGEXP. For REGEXP
                          see "man egrep". If NUMBER is missing and there is only
                          one match or if the pattern matches a line go to that
                          directory. If NUMBER is missing and there is more than
                          one match, list all matches with line numbers.
                          IF REGEXP and NUMBER are missing, go to the directory 
                          that is the top of the stack (the last one dslist 
                          shows).
  dsback                : Go back to that last directory before it was changed by
                          a bash-dirstack command.
  dsedit                : Edit directory stack file.
  dsclear               : Initialize the directory stack with a single entry,
                          which is your home directory.
  dsset [TAG]           : Initialize or use new directory stack file with tag.
                          TAG. If TAG is not given use the standard filename.
  dssetlist             : List existing tags for dsset command.

Your directory stack is kept in a directory in your HOME directory. The default name
of this directory is "DIRSTACK".

How it works  
------------
    
Your directory stack is kept in a directory in your HOME directory. The default
name of this directory is "DIRSTACK", the default filename of the file itself
is "default".

All commands are shell functions or aliases. They use standard linux command
line tools to operate on the directory stack file.

Examples
--------

Bookmarking
+++++++++++

When you operate in your text terminal, each time you want to remember the
current working directory, enter::

  dscdpush

In order to see what paths were remembered, enter::

  dslist

Each path in the stack (from bottom to top) is printed with a leading line
number.

You may go to the last entry (top of stack) without changing the stack with::

  dsngo

Or you may go to an arbitrary directory from the stack with::

  dsngo NUMBER

where NUMBER is a line number shown with "dslist". 

Using string matches and regular expressions
++++++++++++++++++++++++++++++++++++++++++++

When your directory stack has many entries, instead of using "dsngo NUMBER" it
may be easier to use regular expression matching. bash-dirstack uses extended
POSIX regular expressions. See 

You can see which of the paths lists a given REGEXP with::

  dslist REGEXP

If there is only one match you can change to the directory with::

  dsgo REGEXP

If there is more than one match, "dsgo" shows the matches with line numbers.
You can then select a line with::

  dsgo REGEXP NUMBER

Remembering all directories in a workflow
+++++++++++++++++++++++++++++++++++++++++

Instead of "cd DIR" use the dscdpush command::

  dscdpush DIR

With every "dscdpush" command, the given directory is put on the stack.

You can go back to the previous directory with the command::

  dsdropgo

With this approach, you use bash-dirstack exactly like a stack.

Using more than one directory stack
+++++++++++++++++++++++++++++++++++

You can define a new directory stack with::

  dsset NAME

This defines a new directory stack with the given NAME. 

The following command lists all directory stacks::

  dssetlist

Working with more than one terminal
+++++++++++++++++++++++++++++++++++

If you have two text terminals and want to go to the same directory in the
second terminal do the following:

In terminal 1::

  dscdpush

In terminal 2::

  dsngo

