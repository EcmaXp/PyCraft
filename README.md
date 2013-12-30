Python 4 Lua (OpenComputers Only!)
==================================

Python Code to Lua. For OpenComputers

Any helper can help me. Open issue with support this.

## Goal
* We don't need mod but need one lua api and this program.
* We can run python code on OpenComputers.
* Add pure python thing for compiler.

## Limits
* We can't use original python library. (it is special, unlike other real computer)
* Lua are not support undefine (just assign nil is undefine), so no way to detect Undefined Value!
* OpenComputer are limit CPU Time, Memory (in this case, Current Lua Library (not python interpreter) are consume more than 128k)
* OpenComputer and ComputerCraft use different lua, so i decided use OpenComputer.

## TODO
* Python's List (or tuple, dict, set, etc) comprehension are not supported.
* Support Python Modules (one computer hold only one python interpreter.)
* Support Python Bulitins
* Support Iter, If, etc.
* Support str, int, float, tuple, dict, list, set builtins method.
* Rewrite Full Python Translator for simple. (it must dynamic code generator and do not compile if that don't edited)
* Rewrite The Library.
* Code Compresser or Store the function + data for low cpu/memory usage. (almost done with Code Compresser, now i need store thing? (reference))
* MRO Cache by lua_compiler, calcuate C3 MRO are very heavy. (didn't profile)
* Simple error message.

## Check Here
* http://www.lua.org/
* http://www.tinypy.org/
* http://docs.python.org/3.3/
* http://docs.python.org/3.3/reference/datamodel.html
* http://docs.python.org/3.3/library/ast.html
* http://greentreesnakes.readthedocs.org/en/latest/
* https://github.com/MightyPirates/OpenComputers
* http://opencomputers.net/

## Dev Environ
* https://code.google.com/p/pyscripter/
