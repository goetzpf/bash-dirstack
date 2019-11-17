=============
bash-dirstack
=============

A simple implementation of a directory stack for bash.

Motivation
----------

The commands "dirs", "pushd" and "popd" in bash can also manage a directory stack. 

This approach here has the following advantages:

- A single directory stack across *all* terminal windows.
- The directory stack is a text file than can be edited.
- The directory stack is preserved after you log off.
- You can use several directory stacks, each with a different name.
- You can go to the last entry on the stack without removing it from the stack.

How to install
--------------

Add all lines from file "dirstack.sh" to your file .bashrc or include them by adding this line to .bashrc::

  source DIRECTORY/dirstack.sh

DIRECTORY is, of course, the directory where "dirstack.sh" can be found.

Usage
-----

Your shell gets some extra commands::

  PUSH                    : push directory on directory stack
  POP                     : pop directory from directory stack and change directory
  PLIST                   : show directory stack with line numbers
  PEDIT                   : edit directory stack file
  PCLEAR                  : set directory stack to one entry: $HOME
  PGO NUMBER              : go to directory NUMBER
  PSET [TAG]              : create/use new directory stack file with tag TAG. If TAG is
                            not given use the standard filename.
  PSET-LIST               : list existing tags for PSET command

Your directory stack is kept in a file in your HOME directory. The default name of this file is "PATH".

How it works  
------------
    
Your directory stack is kept in a file in your HOME directory. The default name of this file is "PATH".                                    
    
IF you enter "PUSH" your current working directory is appended to this file. If you enter "POP" 
you change to the directory of the last line in the file, and this line is removed.
 
PLIST shows the contents of the file with line numbers. PEDIT calls your default editor to edit this file.
 
PCLEAR removes all lines from the file and put in a single line with the path to your home directory.
 
PGO NUMBER goes to the directory of line NUMBER in the file. You can see the NUMBER you need 
to enter with command PLIST. If you omit NUMBER, you change to the directory of the last line
in the file. The directory stack file is not changed with this command. 
 
PSET defines a new name for the directory stack file. With "PSET NAME" you set the name to 
"PATH.NAME", e.g. "PSET new" sets it to "PATH.new". By this you can maintain more than one directory stack at a time.
 
PSET-LIST lists all directory stack files.
