Python 4 Lua (ComputerCraft Only!)
==================================

Python Code to Lua. For ComputerCraft

Progess 64%

## Goal
* We don't need and mod but need one lua api and this program.
* We can run translated-python-code on computercraft's computer.
* Add New mod for intergrate with python3. (server must install python3 for that, or client)
* Add pure python thing for compile something? (VERY HARD!)

## Limits (Without Mod)
* We can't run python-code on computer directly
* We can't run translater on computer. (use online compiler for later. i will release it.)

## Limits
* We can't use original python library. (it is special, unlike other real computer)
* Lua are not support undefine (just assign nil is undefine), so no way to detect Undefined Value.

## TODO
* Make Python Import Module Library and programs as python module. (one computer hold only one python interpreter)
* Rewrite define, and support types (int, float, list, tuple, dict, set, etc)
* Support Binary Op and other Op
* Support Python Bulitins
* Support str, int, float, tuple, dict, list, set builtins method.
* If i add new mods for ComputerCraft, warp the 
 - lua: function os.run( _tEnv, _sPath, ... )
 - lua: function os.loadAPI( _sPath )
 - api: ILuaContext for compile, execute.

## Check Here
* http://www.computercraft.info/
* http://greentreesnakes.readthedocs.org/en/latest/
* https://pypi.python.org/pypi/astmonkey/0.1.0
* http://docs.python.org/3.3/library/ast.html
* http://www.lua.org/
* http://www.eclipse.org/koneki/ldt/
* https://code.google.com/p/pyscripter/
