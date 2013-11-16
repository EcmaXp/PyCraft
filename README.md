Python 4 Lua (ComputerCraft Only!)
==================================

Python Code to Lua. For ComputerCraft

Currently it is not work, but i will fix before 2013-11-17 (my birthday!)

## Goal
* We don't need and mod but need one lua api and this program.
* We can run translated-python-code on computercraft's computer.
* Add New mod for intergrate with python3. (server must install python3 for that, or client)

## Limits (Without Mod)
* We can't run python-code on computer directly
* We can't run translater on computer. (use online compiler for later. i will release it.)

## Limits
* We can't use original python library. (it is special, unlike other real computer)
* Lua are not support undefine (just assign nil is undefine), so no way to detect Undefined Value.

## TODO
* make Python Import Module Library and programs as python module. (one computer hold only one python interpreter)
* Add NodeVisitor for flat design. no more self.visit(new_AST)
* Rewrite define, and support types (int, float, list, tuple, dict, set, etc)
* Rewrite py.xxx to pyctx.xxx (for assign builtins)
* Support Binary Op and other Op
* Support Python Bulitins
* Support str, int, float, tuple, dict, list, set builtins method.
* Support subscript Assign work.
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

## Detail
### 2 Type's Code

#### Full-Code
* Almost like real world's python.
* Support full syntex for python.
* It need library for running.

#### Lite-Code
* This have only few syntex. for support Full-Code's Python. (likely RPython, but this is too much simple)
* Support some syntex that exists in Lua.
* It don't need any library for run.

### Operator Override
* __getattr__, __setattr__ : use metatable's __index, __newindex
* All other operator: handle by Lite-Code's function (_OP__Add__, etc.)

### Special Override
* try ~ except
* lua's len (rawlen?)

### interact with obj
* Full-Code are can't interact with lua object.
* Lite-Code can interact with lua object.

### define

### module support

### Special Function + Value

### Algoritm
* C3 Mro
* `*args` and `**kwargs`
* assign tuple
* import
* current dir (shell)
* yield (function as coroutine, helper are needed.)

### OP Function(a, b)
```
def _OP__Add__(a, b):
  assert(is_pyobj(x) and is_pyobj(y)
  return (safe_call(a.__add__, b) or safe_call_(b.__radd__, a))[1]
```
* in debug mode: check the type.

### Hooking
* os.run
* os.loadAPI
* fs.open (for pyc)

### Extension
* X (Lite-Code)
* py (Full-Code)
* pyc (Full-Code's Translated Lua Code)

# (Out-dated)
## Work with
* Module
* Num (int, float)
* Str
* Table (List, Tuple, Dict)
* Name
* Expr
* UnaryOp (+, -, not)
* BinOp (+, -, *, /, pow)
* BoolOp(and, or)
* Call
* arg
* IfExp
* Attribute
* Compare(==, !=, <, <=, >, >= (FIX ME), is, is not)
* Subscript
* Index
* Slice
* ExtSlice
* AugAssign (with BinOp)
* Assign (with Sub
* Assert
* Pass
* Import (import some, import some as other)
* If (elif, else)
* For (else)
* While (else)
* Try (try ~ finally only)
* FunctionDef
* Lambda
* Return
* Break
* Continue (For and While stmt only)
* Global
* Nonlocal

## Not Work With
* Class
* Del
* Etc.

## Never Work With
* complex (Num)
* Bytes
* metaclass
