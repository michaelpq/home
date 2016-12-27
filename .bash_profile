#--------------------------------------------------------------------------
# .bash_profile
#	Bash profile settings, loaded when terminal is activated by ssh
#	Copyright (c) 2010-2017, Michael Paquier
#--------------------------------------------------------------------------

# Load .bashrc
if [ -f $HOME/.bashrc ]; then
	. $HOME/.bashrc
fi
