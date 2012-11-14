#--------------------------------------------------------------------------
# .bashrc
#	bash settings
#	Copyright (c) 2010-2012, Michael Paquier
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
# General system setings
#--------------------------------------------------------------------------

# Path settings
# Give priority in scanning to /usr/local/bin for user things like homebrew
# Give also priority to $HOME/pgsql/bin for Postgres and Postgres-XC development
export PATH=/usr/local/bin:$PATH
export PATH=$PATH:$HOME/bin:$HOME/bin/extra

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
	xterm-color) color_prompt=yes;
esac

# Begin to build PS1 for terminal

# Uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi

if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]'
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w'
fi
unset color_prompt force_color_prompt

# Add extension to show git branch of current repository
which git_status_reference &> /dev/null
RES=$?
if [ "$RES" == 0 ]
then
	PS1="$PS1\`git_status_reference\`"
fi

# Finish by adding extension "$" to PS1 and a single space for clarity
PS1="$PS1\$ "

#--------------------------------------------------------------------------
# Alias definitions
#--------------------------------------------------------------------------

# Load alias definitions in external file
# Those commands are kept separate for simplicity
if [ -f ~/.bash_alias ]; then
	. ~/.bash_alias
fi

# Load the extra alias definitions
# This file is ignored by the GIT repository of this system
# So store all the aliases you want to keep private there
if [ -f ~/.bash_alias_extra ]; then
	. ~/.bash_alias_extra
fi

#--------------------------------------------------------------------------
# Development
#--------------------------------------------------------------------------

# Enable core files for all sizes
ulimit -c unlimited

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
if [ -f ~/.bash_extra ]; then
	. ~/.bash_extra
fi

# Load global public parameters of Home
# Those parameters are visible in the GIT repository of Home.
if [ -f ~/.homeconfig ]; then
	. ~/.homeconfig
fi

# Load global private parameters of Home
# Those parameters are not visible in the GIT repository of Home.
if [ -f ~/.homeconfig_extra ]; then
	. ~/.homeconfig_extra
fi
