import ast
from ast import AST

import io
import contextlib
import weakref
import random
TAB_SIZE = 2
TAB = TAB_SIZE * " "
TEMP_VNAME = "X_X"

LUA_True = "true"
LUA_False = "false"
LUA_None = "nil"

class RawRepr(str):
    def __repr__(self):
        return self

def unresolve(value, raw=False, *, has_ast):
    if isinstance(value, AST):
        if has_ast:
            return RawRepr("*")
        else:
            fname = type(value).__name__
            fargs = []
            for key, value in ast.iter_fields(value):
                if isinstance(value, AST):
                    value = unresolve(value, raw=True, has_ast=False)

                fargs.append((key, value))
            fargs = ", ".join("%s=%s" % (key, value) for key, value in fargs)

            return RawRepr('%s(%s)' % (fname, fargs))
    elif isinstance(value, list):
        newvalue = []
        for node in value:
            newvalue.append(unresolve(node, raw=True, has_ast=has_ast))
        return newvalue
    elif raw:
        return value

    return repr(value)

def repr_node(node, *, has_ast):
    #return dump(node, annotate_fields=False)
    result = "%s(%%s)" % (type(node).__name__,)

    attrs = []
    for key, value in ast.iter_fields(node):
        value = unresolve(value, has_ast=has_ast)
        attrs.append((key, value))

    rattrs = ", ".join("%s=%s" % (key, value) for key, value in attrs)
    result = result % rattrs
    return result

class ASTChildVisitor(ast.NodeVisitor):
    def generic_visit(self, node):
        for key, value in ast.iter_fields(node):
            if isinstance(value, AST):
                for k, v in ast.iter_fields(value):
                    if isinstance(v, AST):
                        return True
            elif isinstance(value, list):
                for node in value:
                    if isinstance(node, AST):
                        return True

        return False

class ShowTree(ast.NodeVisitor):
    def __init__(self):
        self.level = 0

    def generic_visit(self, node):
        self.level += 1
        try:
            child_visitor = ASTChildVisitor()
            has_ast = child_visitor.visit(node)

            print((self.level - 1) * "  ", end="")
            print(repr_node(node, has_ast=has_ast))

            if has_ast:
                super().generic_visit(node)
        finally:
            self.level -= 1

with open("py_API.lua") as fp:
    py_API = fp.read()

py_API_FNAMES = set()
for line in py_API.splitlines():
    fname = line.partition("function")[2].partition("(")[0].strip()
    if fname and "." not in fname:
        py_API_FNAMES.add(fname)

class IsControlFlow(Exception):
    pass

class LuaCodeGenerator(ast.NodeVisitor):
    def __init__(self):
        self.reset()

    def reset(self):
        self.indent = 0
        self.fp = io.StringIO()
        self.blocks = [self.new_blockenv()]
        self.lastend = "\n"
        self.lineno = 1

    def print(self, *args, **kwargs):
        fp = self.fp
        if self.lastend == "\n":
            fp.write(self.indent * TAB)
            self.lineno += 1
        self.lastend = kwargs.get("end", "\n")
        print(*args, file=fp, **kwargs)

    def new_blockenv(self):
        return {
            "global_defined" : set(),
            "local_defined" : set(),
            "nonlocal_defined" : set(),
            "defined" : set(),
        }

    @property
    def current_block(self):
        return self.blocks[-1]

    @contextlib.contextmanager
    def block(self):
        self.indent += 1
        self.blocks.append(self.new_blockenv())

        try:
            yield
        finally:
            self.indent -= 1
            self.blocks.pop()

    @contextlib.contextmanager
    def noblock(self):
        try:
            yield
        except IsControlFlow:
            raise ValueError("Control Flow are not excepted.")

    @contextlib.contextmanager
    def hasblock(self):
        try:
            yield
        except IsControlFlow:
            pass

    def generic_visit(self, node):
        raise TypeError("%r are not supported by py2lua" % (type(node),))

    def visit_Module(self, node):
        self.reset()
        print = self.print
        print('-- PYTHON ARE REQUIRE FOR RUN --')
        print("assert(py, 'Require Python API')")
        print("pyctx = py.init_module_context()")
        print("local", TEMP_VNAME, "= nil -- So cute! >_</")
        print()

        for subnode in node.body:
            #print()
            #print("-- [ LINE %i (LUA %i) ] --" % (subnode.lineno, self.lineno))
            with self.hasblock():
                print(self.visit(subnode))

        return self.fp.getvalue()


    # -- Literals -- #
    def visit_Num(self, node):
        with self.noblock():
            if isinstance(node.n, complex):
                raise TypeError("complex are not supported by py2lua")

            return repr(node.n)

    def visit_Str(self, node):
        with self.noblock():
            return repr(node.s)

    def visit_List(self, node):
        with self.noblock():
            return "{%s}" % (", ".join(map(self.visit, node.elts)))

    def visit_Tuple(self, node):
        with self.noblock():
            return "{%s}" % (", ".join(map(self.visit, node.elts)))

    def visit_Dict(self, node):
        with self.noblock():
            has_content = False
            result = "{"

            for key, value in zip(node.keys, node.values):
                has_content = True
                result += "[%s] = %s, " % (self.visit(key), self.visit(value))

            if has_content:
                result = result[:-len(", ")]

            result += "}"
            return result


    # -- Variables -- #
    def visit_Name(self, node):
        with self.noblock():
            name = node.id
            if name == "None":
                return LUA_None
            elif name == "True":
                return LUA_True
            elif name == "False":
                return LUA_False
            elif name == "int":
                return "tonumber"
            elif name == "str":
                return "tostring"
            elif name in py_API_FNAMES:
                return "py." + name
            else:
                return name


    # -- Expressions -- #
    def visit_Expr(self, node):
        with self.noblock():
            return self.visit(node.value)

    def visit_UnaryOp(self, node):
        with self.noblock():
            op = self.visit(node.op)
            operand = self.visit(node.operand)
            return "%s%s" % (op, operand)

    visit_UAdd = lambda self, node: "+"
    visit_USub = lambda self, node: "-"
    visit_Not = lambda self, node: "not "

    def visit_BinOp(self, node):
        # TODO: unwarp /var = (...)/ the union
        #  must ((3 + 2) * 1) => (3 + 2) * 1
        with self.noblock():
            left = self.visit(node.left)
            right = self.visit(node.right)
            op = self.visit(node.op)

            return "(%s%s%s)" % (left, op, right)

    visit_Add = lambda self, node: " + "
    visit_Sub = lambda self, node: " - "
    visit_Mult = lambda self, node: " * "
    visit_Div = lambda self, node: " / "
    visit_Pow = lambda self, node: " ^ "

    def visit_BoolOp(self, node):
        with self.noblock():
            op = self.visit(node.op)
            return "(%s)" % op.join(map(self.visit, node.values))

    visit_And = lambda self, node: " and "
    visit_Or = lambda self, node: " or "

    def visit_Call(self, node):
        with self.noblock():
            func = self.visit(node.func)
            args = ", ".join(map(self.visit, node.args))

            assert not node.keywords
            assert node.starargs is None
            assert node.kwargs is None

            return "%s(%s)" % (func, args)

    def visit_arg(self, node):
        with self.noblock():
            return node.arg

    def visit_IfExp(self, node):
        with self.noblock():
            return "py.ifexp(%s, %s, %s)" % (
                self.visit(node.test),
                self.visit(node.body),
                self.visit(node.orelse),
            )

    def visit_Attribute(self, node):
        with self.noblock():
            name = self.visit(node.value)
            #if name.startswith("_R."):
            #    return name[len("_R."):]
            #else:
            return "%s.%s" % (name, node.attr)

    def visit_Compare(self, node):
        with self.noblock():
            body = [self.visit(node.left)]
            assert node.ops
            assert node.comparators

            for op, value in zip(node.ops, node.comparators):
                value = self.visit(value)

                if isinstance(op, (ast.In, ast.NotIn)):
                    op = op.__class__.__name__
                    last = body.pop()
                    if last.startswith(" and "):
                        last = last[len(" and "):]
                    body.append("py.op.%s(%s, %s)" % (op, last, value))
                else:
                    op = self.visit(op)

                    body.append("%s%s" % (op, value))
                body.append(" and %s" % (value,))
            body.pop()

            return "".join(body)

    visit_Eq = lambda self, node: " == "
    visit_NotEq = lambda self, node: " ~= "
    visit_Lt = lambda self, node: " < "
    visit_LtE = lambda self, node: " <= "
    visit_Gt = lambda self, node: " > "
    visit_GtE = lambda self, node: " <= "
    visit_Is = lambda self, node: " is "
    visit_IsNot = lambda self, node: " is not "


    # -- Subscripting -- #
    # visit_Subscript must be not direct call from visit, it must different
    #  when assign or see the value??
    def visit_Subscript(self, node):
        with self.noblock():
            name = self.visit(node.value)
            if isinstance(node.slice, ast.Index):
                return "py.index(%s, %s)" % (name, self.visit(node.slice))
            else:
                return "py.slicing(%s, %s)" % (name, self.visit(node.slice))

    def visit_Index(self, node):
        with self.noblock():
            return self.visit(node.value)

    def visit_Slice(self, node):
        def visit_SInfo(node):
            if node:
                return self.visit(node)
            return LUA_None

        with self.noblock():
            sinfo = tuple(map(visit_SInfo, (node.lower, node.upper, node.step)))
            return "py.slice(%s, %s, %s)" % sinfo

    def visit_ExtSlice(self, node):
        with self.noblock():
            return "{%s}" % ", ".join(map(self.visit, node.dims))

    # -- Comprehensions -- #


    # -- Statements -- #
    def visit_AugAssign(self, node):
        with self.noblock():
            AssignAST = ast.Assign(targets=[node.target],
            value=ast.BinOp(node.target, node.op, node.value))
            assert self.visit(node.target) in self.current_block["defined"]
            return self.visit(AssignAST)

    def visit_Assign(self, node):
        with self.noblock():
            def visit_TestNeedAssignPack(node):
                if isinstance(node, ast.Call):
                    return True
                else:
                    return False

            tvalue = TEMP_VNAME
            multi = False
            defined = set()
            def localdefine(rawname, add=True):
                if rawname not in self.current_block["defined"]:
                    self.current_block["local_defined"].add(rawname)
                    self.current_block["defined"].add(rawname)

                    if defined is not None:
                        if add:
                            defined.add(rawname)
                        return "local "

                return ""

            if len(node.targets) > 1:
                multi = True
                if visit_TestNeedAssignPack(node.value):
                    result = "%s = py.pack(%s)" % (tvalue, self.visit(node.value))
                else:
                    result = "%s = %s" % (tvalue, self.visit(node.value))
            else:
                result = ""
                tvalue = self.visit(node.value)

            for target in node.targets:
                if isinstance(target, ast.Name):
                    vname = self.visit(target)
                    result += "; %s%s = %s" % (localdefine(vname, add=False), vname, tvalue)
                elif isinstance(target, ast.Attribute):
                    # TODO: fix t.n.g[2] = 1 problem.
                    vname = self.visit(target.value)

                    self.current_block["global_defined"].add(vname)
                    self.current_block["defined"].add(vname)

                    result += "; %s = %s" % (self.visit(target), tvalue)
                elif isinstance(target, ast.Subscript):
                    pname = self.visit(target.value)
                    index = self.visit(target.slice)
                    vname = pname

                    while isinstance(target.value, ast.Attribute):
                        target = target.value
                        vname = target.value

                    vname = self.visit(target.value)
                    self.current_block["global_defined"].add(vname)
                    self.current_block["defined"].add(vname)

                    result += "; py.assign_subscript(%s, %s, %s)" % (pname, index, tvalue)
                elif isinstance(target, ast.Tuple):
                    def visit_AssignTargets(node):
                        if isinstance(node, ast.Name):
                            vname = self.visit(node)
                        elif isinstance(node, ast.Starred):
                            vname = self.visit(node.value)
                        else:
                            raise TypeError("unexcepted %r." % (type(node),))

                        localdefine(vname)
                        return vname

                    var = ", ".join(map(visit_AssignTargets, target.elts))
                    starred = None

                    for no, sub in enumerate(target.elts, 1):
                        if isinstance(sub, ast.Starred):
                            starred = no

                    if starred is None:
                        # TODO: choice one, unpack or py.unpack use.
                        result += "; %s = unpack(%s)" % (var, tvalue)
                    else:
                        result += "; %s = py.unpack(%s, %i)" % (var, tvalue, starred)

            if multi:
                result += "; %s = %s" % (tvalue, LUA_None)
            else:
                assert result.startswith("; ")
                result = result[len("; "):]

            if defined:
                result = "local %s; %s" % (", ".join(defined), result)

            return result

    def visit_Assert(self, node):
        with self.noblock():
            test = self.visit(node.test)
            if not node.msg:
                return "assert(%s)" % (test,)
            else:
                return "assert(%s, %s)" % (test, self.visit(node.msg))

    def visit_Pass(self, node):
        with self.noblock():
            return "%s = %s" % (TEMP_VNAME, LUA_None)

    # -- Imports -- #
    def visit_Import(self, node):
        result = ""
        with self.noblock():
            for alias in node.names:
                assert isinstance(alias, ast.alias)
                result += "; py.import(%r, %s)" % (alias.name, alias.name)
                if alias.asname:
                    AsNameAst = ast.Assign(targets=[
                        ast.Name(id=alias.asname, ctx=ast.Store()),
                    ], value=ast.Name(id=alias.name, ctx=ast.Load()))

                    result += "; %s" % (self.visit(AsNameAst))
                    # TODO: make common local define (or global)

        print = self.print
        print(result[len("; "):])
        raise IsControlFlow

    # -- Control flow -- #
    def visit_If(self, node):
        print = self.print
        print("if", self.visit(node.test), "then")

        with self.block():
            print("local", TEMP_VNAME)
            for subnode in node.body:
                with self.hasblock():
                    print(self.visit(subnode))

        if len(node.orelse) == 1 and isinstance(node.orelse[0], ast.If):
            print("else", end="")
            with self.hasblock():
                self.visit_If(node.orelse[0])
            raise IsControlFlow
        elif node.orelse:
            print("else")
            with self.block():
                for subnode in node.orelse:
                    with self.hasblock():
                        print(self.visit(subnode))

        print("end")
        raise IsControlFlow

    def visit_For(self, node):
        print = self.print

        zrand = random.randint(100000, 999999)
        hascont = False
        contname = ""
        hasbreak = False
        breakname = ""

        target = self.visit(node.target)
        if isinstance(node.target, ast.Tuple):
            # TODO: Common Tuple Assign Interface??
            target = target[+1:-1]

        iter = self.visit(node.iter)
        iter = "py.iter(%s)" % (iter,)

        print("for", target, "in", iter, "do")
        with self.block():
            print("local", TEMP_VNAME)
            for subnode in node.body:
                if isinstance(subnode, ast.Continue):
                    hascont = True
                    contname = "ZCONT_%i" % zrand
                    print("goto", contname, '-- continue')
                elif isinstance(subnode, ast.Break) and node.orelse:
                    hasbreak = True
                    breakname = "ZBREAK_%i" % zrand
                    print("goto", breakname, '-- break')
                else:
                    with self.hasblock():
                        print(self.visit(subnode))

            if hascont:
                print("::", contname, "::", sep="")
        print("end")

        if node.orelse:
            for subnode in node.orelse:
                with self.hasblock():
                    print(self.visit(subnode))

        if hasbreak:
            print("::", breakname, "::", sep="")

        raise IsControlFlow

    def visit_While(self, node):
        print = self.print

        zrand = random.randint(100000, 999999)
        hascont = False
        contname = ""
        hasbreak = False
        breakname = ""

        print("while", self.visit(node.test), "do")
        with self.block():
            print("local", TEMP_VNAME)
            for subnode in node.body:
                if isinstance(subnode, ast.Continue):
                    hascont = True
                    contname = "ZCONT_%i" % zrand
                    print("goto", contname, '-- continue')
                elif isinstance(subnode, ast.Break) and node.orelse:
                    hasbreak = True
                    breakname = "ZBREAK_%i" % zrand
                    print("goto", breakname, '-- break')
                else:
                    with self.hasblock():
                        print(self.visit(subnode))

            if hascont:
                print("::", contname, "::", sep="")
        print("end")

        if node.orelse:
            for subnode in node.orelse:
                with self.hasblock():
                    print(self.visit(subnode))

        if hasbreak:
            print("::", breakname, "::", sep="")

        raise IsControlFlow

    def visit_Try(self, node):
        print = self.print

        assert not node.handlers

        print(TEMP_VNAME, "= {(function()")
        with self.block():
            print("local", TEMP_VNAME)
            for subnode in node.body:
                with self.hasblock():
                    print(self.visit(subnode))
        print("end)()}")
        for subnode in node.finalbody:
            with self.hasblock():
                print(self.visit(subnode))
        print("if not %s[1] then error(%s[2])" % (TEMP_VNAME, TEMP_VNAME))

        raise IsControlFlow

    # -- Function and class definitions -- #
    def visit_FunctionDef(self, node):
        print = self.print
        fname = node.name
        fargs = ", ".join(map(self.visit, node.args.args))
        assert ", arg, " not in ", %s, " % fargs
        if node.args.varargannotation:
            fargs += ", ..."

        assert not node.args.kwonlyargs
        #assert not node.args.varargannotation
        assert not node.args.kwarg
        assert not node.args.kwargannotation
        assert not node.args.defaults
        assert not node.args.kw_defaults
        assert not node.returns

        if fname not in self.current_block["defined"]:
            self.current_block["local_defined"].add(fname)
            self.current_block["defined"].add(fname)
            print("local", end=" ")

        print("function %s(%s)" % (fname, fargs))
        with self.block():
            if node.args.varargannotation:
                print("local %s = arg" % (node.args.varargannotation,))
            for subnode in node.body:
                with self.hasblock():
                    print(self.visit(subnode))
        print("end")
        for decorator in node.decorator_list:
            print("%s = %s(%s)" % (fname, self.visit(decorator), fname))

        raise IsControlFlow

    def visit_Lambda(self, node):
        fargs = ", ".join(map(self.visit, node.args.args))
        assert not node.args.kwonlyargs
        assert not node.args.varargannotation
        assert not node.args.kwarg
        assert not node.args.kwargannotation
        assert not node.args.defaults
        assert not node.args.kw_defaults

        result = "(function(%s) " % fargs
        with self.noblock():
            result += self.visit(node.body)
        result += " end)"

        return result

    def visit_Return(self, node):
        with self.noblock():
            return "return %s" % (self.visit(node.value),)

    def visit_Break(self, node):
        with self.noblock():
            return "break"

    def visit_Global(self, node):
        # TODO: add error if already defined by local but try define with global
        # and mixed local + global + nonlocal + etc.

        innerblock = self.blocks[-1]
        global_defined = innerblock["global_defined"]
        defined = innerblock["defined"]

        for name in node.names:
            global_defined.add(name)
            defined.add(name)

        raise IsControlFlow

    def visit_Nonlocal(self, node):
        innerblock = self.blocks[-1]
        global_defined = innerblock["nonlocal_defined"]
        defined = innerblock["defined"]

        for name in node.names:
            global_defined.add(name)
            defined.add(name)

        raise IsControlFlow

class LuaCodeGeneratorNotSupported(LuaCodeGenerator):
    def check(self, node):
        self.found = set()
        self.visit(node)
        return self.found

    def visit(self, node):
        method = 'visit_' + node.__class__.__name__
        visitor = hasattr(self, method)
        if not visitor:
            self.found.add(node.__class__.__name__)

        self.generic_visit(node)

    def generic_visit(self, node):
        for field, value in ast.iter_fields(node):
            if isinstance(value, list):
                for item in value:
                    if isinstance(item, AST):
                        self.visit(item)
            elif isinstance(value, AST):
                self.visit(value)

code = """\
import os
import peripheral as device
tinfo = 0
tinfo **= 1
a, b = 1, 2
def test():
    test = 1
    def test2():
        nonlocal test
        test = 2
        print(test)
a, b = b, a
"""

def main():
    codetree = ast.parse(code)

    print("===== INPUT ====")
    print(code)

    print("===== TREE =====")
    visitor = ShowTree()
    visitor.visit(codetree)
    print()

    print("===== NON_SUPPORT =====")
    print(LuaCodeGeneratorNotSupported().check(codetree))
    print()

    print("===== OUTPUT =====")
    print(LuaCodeGenerator().visit(codetree))

if __name__ == '__main__':
    main()
