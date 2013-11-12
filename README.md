Python 4 Lua (ComputerCraft Only!)
==================================

Python Code to Lua. For ComputerCraft

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
* Assign
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
* complex (Num)
* Bytes
* Class
* Etc.

## TODO
* make Python Import Module Library and programs as python module. (one computer hold only one python interpreter)
* Add NodeVisitor for flat design. no more self.visit(new_AST)
* Rewrite define, and support types (int, float, list, tuple, dict, set, etc)
* Support Binary Op and other Op
