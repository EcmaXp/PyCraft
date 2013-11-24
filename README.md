Python 4 Lua (ComputerCraft Only!)
==================================

Python Code to Lua. For ComputerCraft

Progess 66%

Any helper can help me. Open issue with support this.

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
* Will not release the 'exec', 'eval', and 'compile', that is expansive resource.

## TODO
* [Syntex] 반복문 내부의 변수 접근이 제한되어 있음. (Lua are don't allow loop's value.)
* {Syntex] currently continue, break are not supported. (goto are not aupport on lua 5.1)
* [Syntex] Python's List (or tuple, dict, set, etc) comprehension are not supported.
* [Syntex] Python's own assign method can't (only lua thing are allowed.)
* [Syntex] Python's own call can't (only *args are supported)
* Support Python Modules (one computer hold only one python interpreter)
* Support Class MRO
* Support Binary Op and other Op
* Support Python Bulitins
* Support str, int, float, tuple, dict, list, set builtins method.
* If i add new mods for ComputerCraft, warp the 
 - lua: function os.run( _tEnv, _sPath, ... )
 - lua: function os.loadAPI( _sPath )

## Check Here
* http://www.computercraft.info/
* http://greentreesnakes.readthedocs.org/en/latest/
* http://docs.python.org/3.3/library/ast.html
* http://ccdesk.afterlifelochie.net/
* http://www.lua.org/
* http://www.eclipse.org/koneki/ldt/
* https://code.google.com/p/pyscripter/
