#--------------------------------------------------------------------------
# .bash_profile
#	Bash profile settings, loaded when terminal is activated by ssh
#	Copyright (c) 2010-2022, Michael Paquier
#--------------------------------------------------------------------------

# Load .bashrc
if [ -f $HOME/.bashrc ]; then
	. $HOME/.bashrc
fi
