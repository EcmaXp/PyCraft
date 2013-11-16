import ast
from _ast import *

import io
import contextlib
import weakref
import random

class ShowTree(ast.NodeVisitor):
    @classmethod
    def unresolve(cls, value, raw=False, *, has_ast):
        if isinstance(value, AST):
            if has_ast:
                return "*"
            else:
                fname = type(value).__name__
                fargs = []
                for key, value in ast.iter_fields(value):
                    if isinstance(value, AST):
                        value = cls.unresolve(value, raw=True, has_ast=False)

                    fargs.append((key, value))
                fargs = ", ".join("%s=%s" % (key, value) for key, value in fargs)

                return '%s(%s)' % (fname, fargs)
        elif isinstance(value, list):
            newvalue = []
            for node in value:
                newvalue.append(cls.unresolve(node, raw=True, has_ast=has_ast))
            return newvalue
        elif raw:
            return value

        return repr(value)

    @classmethod
    def repr_node(cls, node, *, has_ast):
        #return dump(node, annotate_fields=False)
        result = "%s(%%s)" % (type(node).__name__,)

        attrs = []
        for key, value in ast.iter_fields(node):
            value = cls.unresolve(value, has_ast=has_ast)
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

    def __init__(self, node=None):
        self.level = 0

        if node is not None:
            self.visit(node)

    def generic_visit(self, node):
        self.level += 1
        try:
            child_visitor = self.ASTChildVisitor()
            has_ast = child_visitor.visit(node)

            print((self.level - 1) * "  ", end="")
            print(self.repr_node(node, has_ast=has_ast))

            if has_ast:
                super().generic_visit(node)
        finally:
            self.level -= 1

def showtree(node):
    sprinter = ShowTree()
    sprinter.visit(node)

def printcode(code, mode="exec"):
    codetree = ast.parse(code, mode=mode)
    showtree(codetree)

class IsControlFlow(Exception):
    pass

class BaseBlockEnvManager(object):
    def __init__(self, **extra):
        vars(self).update(extra)
        self.reset()

    def reset(self):
        pass

class BaseDefineManager(BaseBlockEnvManager):
    def reset(self):
        self.defined = set()
        self.default_defined = NotImplemented

    def is_defined(self, value):
        return value in self.defined

    def define(self, value, default_defined=None):
        if self.is_defined(value):
            raise RuntimeError("%s are already defined." % (value,))

        self.defined.add(value)

        if default_defined is None:
            if self.default_defined is NotImplemented:
                raise NotImplementedError("default_defined are not implemented.")
            self.default_defined.add(value)

        return True

class CommonDefineManager(BaseDefineManager):
    def reset(self):
        super().reset()

        self.global_defined = set()
        self.local_defined = set()

    def global_define(self, value):
        return self.define(value, self.global_defined)

    def local_define(self, value):
        return self.define(value, self.local_defined)

class LuaDefineManager(CommonDefineManager):
    def reset(self):
        super().reset()

        self.default_defined = self.global_defined

class PythonDefineManager(CommonDefineManager):
    def reset(self):
        super().reset()

        self.nonlocal_defined = set()
        self.default_defined = self.local_defined

    def nonlocal_define(self, value):
        return self.define(value, self.nonlocal_defined)

class LuaBlockEnvManger(PythonDefineManager):
    pass

class PythonBlockEnvManger(PythonDefineManager):
    pass

class BlockBasedNodeVisitor(ast.NodeVisitor):
    def __init__(self):
        self.reset()

    def reset(self):
        self.indent = 0
        self.blocks = [self.new_blockenv(first=True)]

    def new_blockenv(self, **extra):
        raise NotImplementedError

    @property
    def current_block(self):
        return self.blocks[-1]

    @contextlib.contextmanager
    def block(self):
        block_env = self.new_blockenv()
        self.enter_block(block_env)
        self.blocks.append(block_env)

        try:
            yield
        finally:
            self.blocks.pop()
            self.exit_block(block_env)

    def enter_block(self, block_env):
        pass

    def exit_block(self, block_env):
        pass

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

    def not_support_error(self, obj, action):
        raise TypeError("%s %r are not supported by %s" % (action, obj, type(self).__name__))

class BlockBasedCodeGenerator(BlockBasedNodeVisitor):
    def reset(self):
        super().reset()
        self.fp = io.StringIO()
        self.lastend = "\n"
        self.lineno = 1

    def enter_block(self, block_env):
        self.indent += 1
        super().enter_block(block_env)

    def exit_block(self, block_env):
        self.indent -= 1
        super().exit_block(block_env)

    def print(self, *args, **kwargs):
        fp = self.fp
        if self.lastend == "\n":
            fp.write(self.indent * self.TAB)
            self.lineno += 1
        self.lastend = kwargs.get("end", "\n")
        print(*args, file=fp, **kwargs)

    def generic_visit(self, node):
        self.not_support_error(node, action="work with")

class FullPythonCodeTransformer(ast.NodeTransformer, BlockBasedNodeVisitor):
    def new_blockenv(self, **extra):
        extra.update(vtemp=0)
        return PythonBlockEnvManger(**extra)

    def visit(self, node):
        if not getattr(node, "translated", False):
            return super().visit(node)
        return node

    def rvisit(self, node):
        return self.generic_visit(node)

    def rfix(self, node):
        node.translated = True
        return node

    def get_tvar(self):
        self.current_block.vtemp += 1
        vname = "_TEMP__%i__" % self.current_block.vtemp
        self.current_block.local_define(vname)

        return vname

    def make_call(self, fname, *args):
        return self.rfix(Call(
            func=Name(fname, Load()),
            args=list(map(self.rvisit, args)),
            keywords=[],
            starargs=None,
            kwargs=None,
        ))

    def make_literal(self, node, *, fname=None):
        # TODO: disable some object by apply rvisit.
        fname = fname.__name__ or type(node).__name__.lower()
        return self.rfix(Call(
            func=Name(fname, Load()),
            args=[node],
            keywords=[],
            starargs=None,
            kwargs=None,
        ))

    def make_op(self, operand, *op):
        fname = "_OP__%s__" % type(operand).__name__
        return self.make_call(fname, *op)

    def make_static_op(self, operand, *op):
        fname = "_OP__%s__" % operand
        return self.make_call(fname, *op)

    def visit_Num(self, node):
        return self.make_literal(node, fname=type(node.n))

    def visit_Str(self, node):
        return self.make_literal(node, fname=type(node.s))

    def visit_List(self, node):
        node = self.rvisit(node)
        return self.make_literal(node, fname=type(node.elts))

    def visit_Tuple(self, node):
        node = self.rvisit(node)
        return self.make_literal(node, fname=type(node.elts))

    def visit_Dict(self, node):
        node = self.rvisit(node)
        return self.make_literal(node, fname=type(node.elts))

    def visit_Set(self, node):
        node = self.rvisit(node)
        return self.make_literal(node, fname=type(node.elts))

    def visit_UnaryOp(self, node):
        return self.make_op(node.operand, node.op)

    def visit_BinOp(self, node):
        return self.make_op(node.op, node.left, node.right)

    def visit_BoolOp(self, node):
        return self.make_op(node.op, *node.values)

##    def visit_Call(self, node):
##        with self.noblock():
##            func = self.visit(node.func)
##            args = ", ".join(map(self.visit, node.args))
##
##            assert not node.keywords
##            assert node.starargs is None
##            assert node.kwargs is None
##
##            return "%s(%s)" % (func, args)

    def visit_Compare(self, node):
        ret = self.visit(node.left)

        for op, value in zip(node.ops, node.comparators):
            value = self.visit(value)
            ret = self.make_op(op, ret, value)

        return ret

    def visit_Subscript(self, node):
        return self.make_op(node, node.value, node.slice)

    def visit_Index(self, node):
        return self.rvisit(node.value)

    def visit_Slice(self, node):
        fname = type(node).__name__.lower()
        return make_call(fname, node.lower, node.upper, node.step)

    def visit_ExtSlice(self, node):
        return self.rvisit(Tuple(list(map(self.rvisit, node.dims))))

    def visit_AugAssign(self, node):
        return Assign(
            targets=[self.rvisit(node.target)],
            value=self.make_op(node, node.target, node.op, node.value),
        )

    def visit_Assign(self, node):
        if len(node.targets) > 1:
            vtemp = Name(self.get_tvar(), Load())

            result = [vtemp]
            result.append(self.visit_Assign(Assign(
                targets = [vtemp],
                value = node.value,
            )))

            for target in node.targets:
                result.append(Assign(
                    targets = [target],
                    value = vtemp,
                ))

            return result

        # Starred
        def nest(target, value):
            if isinstance(target, Tuple): # or List
                vtemp = Name(self.get_tvar(), Store())
                vcount = Name(self.get_tvar(), Store())

                ret = []
                # value = iter(value)
                ret.append(Assign([vtemp], value))

                idx_starred = None
                for idx, subtarget in enumerate(target.elts):
                    if isinstance(subtarget, Starred):
                        idx_starred = idx

                def nest2(idx, subtarget):
                    if isinstance(subtarget, Starred):
                        vsubtemp = Name(self.get_tvar(), Store())
                        for i in range(len(target.elts) - idx):
                            nest2(idx, subtarget)

                        subvalue = vsubtemp
                    else:
                        subvalue = self.make_static_op("Next", vtemp)

                    ret.append(AugAssign(
                        vcount,
                    ))
                    ret.append(nest(subtarget, subvalue))

                for idx, subtarget in enumerate(target.elts):
                    nest2(idx, subtarget)

                make_static_op()

                fname = "_ERR__%s%s__" % ( # _OP__AssignTuple__
                    type(node).__name__,
                    type(target).__name__,
                )

                ret.append(self.make_call(fname, vname, Num(n=len(target))))
                return ret
            elif isinstance(target, Name) or isinstance(target, Attribute):
                return [Assign([target], value)]
            elif isinstance(target, Subscript):
                return [self.make_op(target, target.value, target.slice, value)]

        node.value = self.visit(node.value)
        return nest(node.targets[0], node.value)

    def visit_Assert(self, node):
        return self.make_op(node, node.test, node.msg)

    def visit_Delete(self, node):
        return self.visit(Assign(node.targets, Name("lua.nil", Load()))) # FIXME

    def get_const(self, obj):
        assert obj is None or obj is True or obj is False # or obj is Ellipsis
        return Name("_CONST__%s__" % repr(obj), Load())

    def visit_Import(self, node):
        ret = []

        for alias in node.names:
            target = alias.asname or alias.name
            value = Str(alias.name)

            ret.append(self.visit(Assign(
                Name(target, Store()),
                self.make_call("__import__", value),
            )))
            # TODO: from some import *, or as
            # ONLY import some and import some as other are supported.

        return ret

    def visit_If(self, node):
        node_test = self.visit(Compare(
            left=self.make_static_op(
                "Bool",
                node.test,
            ),
            ops=[Eq()],
            comparators=[self.get_const(True)],
        ))

        del node.test
        self.rvisit(node)
        node.test = node_test

        return node

    def visit_IfExp(self, node):
        return self.visit_If(node)

    def visit_For(self, node):
        vtemp = self.get_tvar()
        node_target = node.target
        node.target = vtemp
        node.iter = self.make_static_op(
            "Iter",
            node.iter,
        )

        node.body.insert(0, Assign(node_target, vtemp))
        node.body = self.visit(node.body)
        return node

class LiteLuaGenerator(BlockBasedCodeGenerator):
    TAB_SIZE = 2
    TAB = TAB_SIZE * " "

    def new_blockenv(self, **extra):
        return PythonBlockEnvManger()

    def generic_visit(self, node):
        self.not_support_error(node, action="work with")

    def visit_Module(self, node):
        self.reset()
        print = self.print

        for subnode in node.body:
            with self.hasblock():
                print(self.visit(subnode))

        return self.fp.getvalue()

    def visit_Num(self, node):
        return repr(node.n)

    def visit_Str(self, node):
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
            return node.id

    # -- Expressions -- #
    def visit_Expr(self, node):
        with self.noblock():
            return self.visit(node.value)

    def visit_Call(self, node):
        with self.noblock():
            func = self.visit(node.func)
            args = list(map(self.visit, node.args))

            assert not node.keywords
            assert node.kwargs is None

            if node.starargs:
                assert(node.starargs, Starred)
                args.append("unpack(%s)" % (self.visit(node.starargs)))

            args = ", ".join(args)
            return "%s(%s)" % (func, args)

    def visit_arg(self, node):
        with self.noblock():
            return node.arg

    def visit_Assign(self, node):
        with self.noblock():
            assert len(node.targets) == 1, node.targets
            block = self.current_block
            target = self.visit(node.targets[0])
            value = self.visit(node.value)

            define = ""
            if not block.is_defined(target):
                define = "local "
                block.define(target)

            return "%s%s = %s" % (define, target, value)

    def visit_Pass(self, node):
        raise IsControlFlow

    def visit_If(self, node):
        print = self.print
        print("if", self.visit(node.test), "then")

        with self.block():
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
        iter = self.visit(node.iter)

        print("for", target, "in", iter, "do")
        with self.block():
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

    # -- Function and class definitions -- #
    def visit_FunctionDef(self, node):
        print = self.print
        fname = node.name
        fargs = list(map(self.visit, node.args.args))

        vararg = node.args.vararg
        if vararg:
            fargs.append("...")

        #assert not node.args.vararg
        assert not node.args.kwonlyargs
        assert not node.args.varargannotation
        assert not node.args.kwarg
        assert not node.args.kwargannotation
        assert not node.args.defaults
        assert not node.args.kw_defaults
        assert not node.returns

        block = self.current_block
        if not block.is_defined(fname):
            block.local_define(fname)
            print("local", end=" ")

        fargs = ", ".join(fargs)
        print("function %s(%s)" % (fname, fargs))
        with self.block():
            block = self.current_block
            if vararg:
                block.local_define(vararg)
                print("local %s = {...}" % (vararg,))

            for subnode in node.body:
                with self.hasblock():
                    print(self.visit(subnode))
        print("end")

        for decorator in node.decorator_list:
            print("%s = %s(%s)" % (fname, self.visit(decorator), fname))

        raise IsControlFlow

    def visit_Lambda(self, node):
        with self.noblock():
            args = list(map(self.visit, node.args.args))

        vararg = node.args.vararg
        if vararg:
            args.append("...")

        assert not node.args.kwonlyargs
        assert not node.args.varargannotation
        assert not node.args.kwarg
        assert not node.args.kwargannotation
        assert not node.args.defaults
        assert not node.args.kw_defaults

        class LambdaVarargTransfomer(ast.NodeTransformer):
            def visit_Name(self, node):
                if node.id == vararg:
                    return List([Name("...", Load())], Store()) # FIXME
                return node

        if vararg:
            transformer = LambdaVarargTransfomer()
            node.body = transformer.visit(node.body)

        args = ", ".join(args)
        result = "(function(%s) " % args
        with self.noblock():
            result += self.visit(node.body)
        result += " end)"

        return result

    def visit_Return(self, node):
        return "return %s" % self.visit(node.value)

    def visit_Break(self, node):
        return "break"

    def visit_Global(self, node):
        block = self.current_block
        for name in node.names:
            block.global_define(name)

        # self.print("-- global %s" % ", ".join(node.names))
        raise IsControlFlow

    def visit_Nonlocal(self, node):
        block = self.current_block
        for name in node.names:
            block.nonlocal_define(name)

        # self.print("-- nonlocal %s" % ", ".join(node.names))
        raise IsControlFlow

    # visit_Raise... how to?

code = """\
if 3:
    print("!")

global node
node = (1, 2, 3)
print(3, *node)
lambda *test: print(*test)

def test(a, b, c, *d):
    pass

for i in pairs(t):
    pass

while True:
    print(2)
"""

def main():
    codetree = ast.parse(code, mode="exec")

    print("===== INPUT ====")
    print(code)

    print("===== TREE (FULL) =====")
    showtree(codetree)
    print()

    LITE = 0
    if LITE:
        print("===== TREE (LITE) =====")
        cls = FullPythonCodeTransformer()
        cls.visit(codetree)

        showtree(codetree)
        print()

    print("===== OUTPUT =====")
    print(LiteLuaGenerator().visit(codetree))

if __name__ == '__main__':
    main()
