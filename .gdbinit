#--------------------------------------------------------------------------
# .gdbinit
#	Settings for gdb
#	Copyright (c) 2010-2015, Michael Paquier
#--------------------------------------------------------------------------

# Custom macros that help in the case of Postgres
macro define __builtin_offsetof(T, F) ((int) &(((T *) 0)->F))
macro define __extension__
macro define AssertVariableIsOfTypeMacro(x, y) ((void)0)

# Keep track of command history for reuse across sessions
set history filename ~/.gdb_history
set history save
