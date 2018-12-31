#--------------------------------------------------------------------------
# .bashrc
#	bash settings
#	Copyright (c) 2010-2019, Michael Paquier
#--------------------------------------------------------------------------

# If not running interactively, do nothing
[ -z "$PS1" ] && return

#--------------------------------------------------------------------------
# History settings
#--------------------------------------------------------------------------

# Don't put duplicate lines in the history. See bash(1) for more options
# Don't overwrite GNU Midnight Commander's setting of `ignorespace'.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
export HISTCONTROL=ignoreboth
# Append to the history file, don't overwrite it
shopt -s histappend
# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)

#--------------------------------------------------------------------------
# Development
#--------------------------------------------------------------------------

# Enable core files for all sizes
ulimit -c unlimited

# Enable git completion script
. $HOME/.git_completion

# Enable git prompt
. $HOME/.git_prompt

#--------------------------------------------------------------------------
# General system setings
#--------------------------------------------------------------------------

# Path settings
# Give priority in scanning to /usr/local/bin for brew on OSX. This is
# set up here for the next settings that may involve binary calls in
# PATH.
export PATH=/usr/local/bin:$PATH
export PATH=$PATH:$HOME/bin

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

#--------------------------------------------------------------------------
# Environment variables
#--------------------------------------------------------------------------

# Those variables should be loaded before aliases or extra commands as
# they could use what is loaded here.

# Load environment variables for system colors.
# Those variables are loaded first as they depend on nothing else.
if [ -f $HOME/bin/system_colors ]; then
    . $HOME/bin/system_colors
fi

# Load global public parameters of Home.
# Those parameters are visible in the GIT repository of Home.
if [ -f $HOME/.homeconfig ]; then
	. $HOME/.homeconfig
fi

# Load global private parameters of Home.
# Those parameters are not visible in the GIT repository of Home.
if [ -f $HOME/.homeconfig_extra ]; then
	. $HOME/.homeconfig_extra
fi

#--------------------------------------------------------------------------
# Terminal
#--------------------------------------------------------------------------

# Build PROMPT_COMMAND for terminal status. This is based on the process
# of ~/.git_prompt fetched from git itself. PROMPT_COMMAND is prefered to
# PS1 because it is slightly faster. Please refer to this script as well
# about the additional settings available that can be set through
# environment variables. Template available in spatch gives as well more
# details about them. The 3rd argument represents the output format of
# printf using the first two arguments. Here we do not print out any
# spaces to save some space. We save the current working directory at each
# status change.
PROMPT_COMMAND='pwd > "${HOME_CWD}"; __git_ps1 "\u@\h:\w" "\\\$ " "(%s%s)"'

# Dynamically set the title of the terminal tab. The following routine
# is in charge of capturing what is going to show up in it. For now and
# to keep things simple, only the last command run will appear in the
# title itself. When the command used is EDITOR, just add the name of the
# file open as title.
function settitle () {
	CURRENT_COMMAND=${@}

	# Just print one command. The ESC character is \033, and the
	# bell character is \007. The following rules allow the title fields
	# to be updated dynamically via PROMPT_COMMAND:
	# 1) ESC]0;stringBEL -- Set icon name and window title to string
	# 2) ESC]1;stringBEL -- Set icon name to string
	# 3) ESC]2;stringBEL -- Set window title to string
	if [ "$PREV_COMMAND" = "" ]; then
		# Check that the current command part matches EDITOR. git-open
		# and "git open" are exceptions present in this environment so
		# handle them as well. If there is no match just use the first
		# command launched and show it in title.
		if [[ "${CURRENT_COMMAND}" == "${EDITOR}"* || \
			  "${CURRENT_COMMAND}" == "git open"*  || \
			  "${CURRENT_COMMAND}" == "git-open"* ]]; then
			# Get the last part of the file defined here. We only
			# want that in the window title to keep things short.
			# XXX: Initialization goes through here as well. Why?
			LAST_PART=${CURRENT_COMMAND##* }
			# Remove as well newlines from the output, those are proving
			# to show up to the user anyway, troubling the result they
			# would expect.
			LAST_PART=${LAST_PART##*'\n'}
			LAST_PART=$(basename "$LAST_PART")
			echo -ne "\033]0;${LAST_PART}\007"
		else
			# Remove as well newlines from the output, those are proving
			# to show up to the user anyway, troubling the result they
			# would expect.
			CURRENT_COMMAND=${CURRENT_COMMAND##*'\n'}
			echo -ne "\033]0;${CURRENT_COMMAND}\007"
		fi

		# Prevent analysis of next sub-command(s). This keyword
		# could be anything actually.
		export PREV_COMMAND=done
	fi
}

# Reset the command previously set
export PROMPT_COMMAND=${PROMPT_COMMAND}'; export PREV_COMMAND=""'

# This abuses the DEBUG signal too much, perhaps there are better and
# cleaner methods.
trap 'settitle "$BASH_COMMAND"' DEBUG

#--------------------------------------------------------------------------
# Compilation and development settings
#--------------------------------------------------------------------------

# LIBRARY_PATH is used by gcc before compilation to search for directories
# containing libraries that need to be linked to your program
export LIBRARY_PATH=$HOME_POSTGRES_INSTALL/lib

# Library paths
# LD_LIBRARY_PATH is used to search for directories containing the libraries
# after it has been successfully compiled and linked.
export LD_LIBRARY_PATH=$HOME_POSTGRES_INSTALL/lib

# Header paths
export C_INCLUDE_PATH=$HOME_POSTGRES_INSTALL/include

# Include Postgres binaries in PATH. Priority is given to them, so add
# then in first position.
export PATH=$HOME_POSTGRES_INSTALL/bin:$HOME_BIN_EXTRA:$PATH

# Include Postgres man folder in MANPATH
export MANPATH=$HOME_POSTGRES_INSTALL/share/man:$MANPATH

#--------------------------------------------------------------------------
# Alias definitions
#--------------------------------------------------------------------------

# Load alias definitions in external file
# Those commands are kept separate for simplicity
if [ -f $HOME/.bash_alias ]; then
	. $HOME/.bash_alias
fi

# Load the extra alias definitions
# This file is ignored by the GIT repository of this system
# So store all the aliases you want to keep private there
if [ -f $HOME/.bash_alias_extra ]; then
	. $HOME/.bash_alias_extra
fi

#--------------------------------------------------------------------------
# Others
#--------------------------------------------------------------------------

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

# Extra bash commands, bash_extra is ignored by the
# GIT repository of this system, so store there information
# you want to keep private.
if [ -f $HOME/.bash_extra ]; then
	. $HOME/.bash_extra
fi

# Switch to the current working directory if any defined.
if [ -f "$HOME_CWD" ]; then
	cd "$(< ${HOME}/.cwd)"
fi
