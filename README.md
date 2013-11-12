Python 4 Lua (ComputerCraft Only!)
==================================

Python Code to Lua. For ComputerCraft

## Check Here
* http://www.computercraft.info/
* http://greentreesnakes.readthedocs.org/en/latest/
* https://pypi.python.org/pypi/astmonkey/0.1.0
* http://docs.python.org/3.3/library/ast.html
* http://www.lua.org/

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

## TODO
* make Python Import Module Library and programs as python module. (one computer hold only one python interpreter)
* Add NodeVisitor for flat design. no more self.visit(new_AST)
* Rewrite define, and support types (int, float, list, tuple, dict, set, etc)
* Rewrite py.xxx to pyctx.xxx (for assign builtins)
* Support Binary Op and other Op
* Support Python Bulitins
* Support str, int, float, tuple, dict, list, set builtins method.
* Support subscript Assign work.
