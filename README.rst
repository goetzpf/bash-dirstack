=================
bash-dirstack 3.1
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

  help:
  
      dshelp TOPIC          : Print help.
                              When TOPIC is "all", print complete help, when
                              TOPIC is "list", list all known commands. When
                              TOPIC is neither "all" nor "list", interpret it as
                              a name of a command and display help for that
                              command.
  
  Push/Pop *without* current working dir on the stack:
  
      dsp [DIR]             : An alias for dspush.
      dspush [DIR]          : Put the current working directory on the top of the
                              directory stack. Then, if DIR is given, go to
                              directory DIR.
      dspop                 : Remove top of the directory stack and go to that
                              directory.
  
  Push/Pop *with* current working dir on the stack:
  
      dsPop                 : Remove top of the directory stack and go to the
                              directory that is now the top of the stack.
      dsPush [DIR]          : If DIR is given, go to DIR and put it on the top of
                              the directory stack. If DIR is not given, push the
                              current working directory on top of directory
                              stack.
  
  Go to arbitrary dir from the stack:
  
      dsngo [NUMBER]        : Go to directory in line NUMBER in the directory
                              stack. The line numbers can be seen with dslist. If
                              NUMBER is omitted, go to the directory that is the
                              top of the stack (the last one dslist shows).
      dsgo [REGEXP] [NUMBER]: Go to match NUMBER in the list of directories from
                              the stack that match regular expression REGEXP. For
                              REGEXP see "man egrep".  If NUMBER is missing and
                              there is only one match or if the pattern matches a
                              line go to that directory. If NUMBER is missing and
                              there is more than one match, list all matches with
                              line numbers.  IF REGEXP and NUMBER are missing, go
                              to the directory that is the top of the stack (the
                              last one dslist shows).
  
  Query the directory stack:
  
      dslist [REGEXP]       : Show directory stack with line numbers. The stack
                              is shown from bottom (first line) to top (last
                              line). If REGEXP is given, show a list with line
                              numbers of matching directories in the directory
                              stack. For REGEXP see "man egrep".
  
  Modify the directory stack:
  
      dsput DIR             : Put directory DIR on top of the directory stack but
                              do not change the current working directory.
      dsdrop                : Remove top of the directory stack but do not change
                              the current working directory.
      dsedit                : Edit directory stack file.
      dsclear               : Initialize the directory stack with a single entry,
                              which is your home directory.
      dssort                : Apply "sort -u" to the directory stack file. This means
                              that all entries are sorted and unique. Note that there
                              is no undo command for this.
  
  Manage more than one directory stack:
  
      dsset [TAG]           : Initialize or use new directory stack file with tag TAG.
                              If TAG is not given show thw current directory stack name.
                              If the stack file does not yet exist, the program asks for
                              confirmation. The TAG is remembered globally in file
                              "CONFIG" as new default for the directory stack file.
      dssetlist             : List existing tags for dsset command.
  
  Revert the last directory change:
  
      dsback                : Go back to that last directory before it was
                              changed by a bash-dirstack command.

Your directory stack is kept in a directory in your HOME directory. The default
name of this directory is "DIRSTACK".

Command completion
------------------

All commands that accept an argument have command completion. If you press
<TAB> one or more times, suggestions for the following argument are displayed.
If you enter the first characters of a command and press <TAB> again, bash
tries to complete the command as far as possible. If you press <ENTER> the
command with the argument displayed so far is executed.

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

When you work in your text terminal, each time you want to remember the
current working directory, enter this command::

  dspush

In order to see what paths were remembered, enter::

  dslist

Each path in the stack (from bottom to top) is printed with a leading line
number.

You may go to the last entry (top of stack) without changing the stack with::

  dsgo

Or you may go to an arbitrary directory from the stack with::

  dsgo DIR

where DIR is a directory or the first characters of a directory shown by
"dslist". Note that dsgo has even more capabilities. See also the following
chapter. You may also want to use command "dsngo".

Using string matches and regular expressions
++++++++++++++++++++++++++++++++++++++++++++

The "dsgo" command mentioned before actually takes a regular expression as
argument, not just a simple string. bash-dirstack uses extended POSIX regular
expressions. 

You can see which entries in the directory stack match a given REGEXP with::

  dslist REGEXP

If there is only one match you can change to the directory with::

  dsgo REGEXP

If there is more than one match, "dsgo" shows the matches with line numbers.
You can then select a line with::

  dsgo REGEXP NUMBER

Workflow for remembering directories excluding the current one
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Instead of "cd DIR" use the dspush command::

  dspush DIR

With every "dspush" command, the current working directory is put on the stack
before the command changes to the new directory.

You can go back to the previous directory with the command::

  dspop

With this approach, you use bash-dirstack exactly like a stack, but the current
working directory is not part of the stack.

If you want to save the current working directory on the stack, enter::

  dspush

Note that you can also enter "dsp" instead of "dspush".

Workflow for remembering directories including the current one
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Instead of "cd DIR" use the dsPush command. Note that this command with capital
"P" is different from "dspush" as described above::

  dsPush DIR

With every "dsPush" command, the current working directory is changed to DIR and
then DIR is put on the stack.

You can go back to the previous directory with the dsPop command. Note that
this command with capital "P" is different from "dspop" as described above::

  dsPop

With this approach, you use bash-dirstack exactly like a stack where the
current working directory is always on the top of the stack.

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

  dspush

In terminal 2::

  dsgo

