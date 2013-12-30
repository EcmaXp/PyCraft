import ast
from _ast import *
import sys
import os
import io
import contextlib
import weakref
import random
import linecache
import subprocess

CTYPE_LITE = "LITE"
CTYPE_FULL = "FULL"
LUA_EXECUTE = "tools/lua/lua52.exe"

__all__ = [
    "lua_compile", "compress_lua_code",
    "print_ast", "print_ast_tree", "full_copy_location",
]

OBJECT_ATTRS = [
    # MUST NOT CHANGE ORDER!

    # START BASIC
    '__new__',
    '__init__',
    '__del__',
    '__repr__',
    '__str__',
    '__bytes__',
    '__format__',
    '__lt__',
    '__le__',
    '__eq__',
    '__ne__',
    '__gt__',
    '__ge__',
    '__hash__',
    '__bool__',
    '__getattr__',
    '__getattribute__',
    '__setattr__',
    '__delattr__',
    '__dir__',
    '__get__',
    '__set__',
    '__delete__',
    '__slots__',
    '__call__',
    '__len__',
    '__getitem__',
    '__setitem__',
    '__delitem__',
    '__iter__',
    '__reversed__',
    '__contains__',
    '__add__',
    '__sub__',
    '__mul__',
    '__truediv__',
    '__floordiv__',
    '__mod__',
    '__divmod__',
    '__pow__',
    '__lshift__',
    '__rshift__',
    '__and__',
    '__xor__',
    '__or__',
    '__radd__',
    '__rsub__',
    '__rmul__',
    '__rtruediv__',
    '__rfloordiv__',
    '__rmod__',
    '__rdivmod__',
    '__rpow__',
    '__rlshift__',
    '__rrshift__',
    '__rand__',
    '__rxor__',
    '__ror__',
    '__iadd__',
    '__isub__',
    '__imul__',
    '__itruediv__',
    '__ifloordiv__',
    '__imod__',
    '__ipow__',
    '__ilshift__',
    '__irshift__',
    '__iand__',
    '__ixor__',
    '__ior__',
    '__neg__',
    '__pos__',
    '__abs__',
    '__invert__',
    '__complex__',
    '__int__',
    '__float__',
    '__round__',
    '__index__',
    '__enter__',
    '__exit__',
    # END BASIC

    # START EXTRA
    '__lua__',
    # END EXTRA

    # NEXT METHOD ARE HERE
]

assert OBJECT_ATTRS[42 - 1] == '__rshift__'
assert OBJECT_ATTRS.index("__pos__") == 72 - 1

PYTHON_KEYWORDS = {
    'False',
    'None',
    'True',
    'and',
    'as',
    'assert',
    'break',
    'class',
    'continue',
    'def',
    'del',
    'elif',
    'else',
    'except',
    'finally',
    'for',
    'from',
    'global',
    'if',
    'import',
    'in',
    'is',
    'lambda',
    'nonlocal',
    'not',
    'or',
    'pass',
    'raise',
    'return',
    'try',
    'while',
    'with',
    'yield',
}

LUA_TRUE = "true"
LUA_FLASE = "false"
LUA_NONE = "nil"

LUA_CONST = {
    LUA_TRUE,
    LUA_FLASE,
    LUA_NONE,
}

PY_TRUE = "True"
PY_FALSE = "False"
PY_NONE = "None"

PY_CONST = {
    PY_TRUE,
    PY_FALSE,
    PY_NONE,
}

LUA_KEYWORDS_WITHOUT_CONST = {
    'and',
    'break',
    'do',
    'else',
    'elseif',
    'end',
    'for',
    'function',
    'if',
    'in',
    'local',
    'not',
    'or',
    'repeat',
    'return',
    'then',
    'until',
    'while',
}

LUA_KEYWORDS = LUA_KEYWORDS_WITHOUT_CONST | LUA_CONST

SPECIAL_NAMES = {"LUA_CODE"} | (LUA_KEYWORDS - PYTHON_KEYWORDS)
SPECIAL_NAMES = {
    'LUA_CODE', # THIS IS LITE LUA's INTERNAL API NAME (FOR EXECUTE LUA CODE)
    'do',
    'elseif',
    'end',
    'false',
    'function',
    'local',
    'nil',
    'repeat',
    'then',
    'true',
    'until'
}

LOCAL = "local"
GLOBAL = "global"
NONLOCAL = "nonlocal"
EMPTY = ""

class FullCopyLocation(ast.NodeVisitor):
    def __init__(self, node):
        self.node = node

    def generic_visit(self, node):
        node = ast.copy_location(node, self.node)
        super().generic_visit(node)
        return node

def full_copy_location(a, b):
    return FullCopyLocation(b).visit(a)

class ASTTreeprinter(ast.NodeVisitor):
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

def print_ast_tree(node):
    printer = ASTTreeprinter()
    printer.visit(node)

def print_ast(code, mode="exec"):
    codetree = ast.parse(code, mode=mode)
    print_ast_tree(codetree)

class IsControlFlow(Exception):
    pass

class SpeicalContext(dict):
    def __init__(self):
        self.__dict__ = self

    def __getattr__(self, name):
        return None

    def copy(self):
        data = super().copy()
        cls = type(self)
        new = cls()
        new.update(data)
        return new

class BaseBlockEnvManager(object):
    def __init__(self, *, parent=None, **extra):
        self.parent = parent
        vars(self).update(extra)
        self.reset()
        self.vaild()

    def reset(self):
        self.special = SpeicalContext()

class BaseDefineManager(BaseBlockEnvManager):
    def reset(self):
        super().reset()
        self.defined = {}
        self.default_define_type = NotImplemented

    def vaild(self):
        assert self.default_define_type in self.defined, self.default_define_type

    def is_defined(self, value):
        for ctx in self.defined.values():
            if value in ctx:
                return True

        return False

    def get_define_type(self, name):
        for key, value in self.defined.items():
            if name in value:
                return key

        return None

    def define(self, name, define_type=None, *, var_info=None):
        if self.is_defined(name):
            raise RuntimeError("%s are already defined." % (name,))

        if define_type is None:
            define_type = self.default_define_type

        self.defined[define_type][name] = var_info
        return True

    def get_define_value(self, name):
        for key, value in self.defined.items():
            if name in value:
                return value[name]

        return None

    def define_short(self, name):
        if not self.is_defined(name):
            self.define(name)

            define_type = self.get_define_type(name)
            if define_type:
                return define_type

        return ""

    def set_default_define(self, types):
        self.default_define_type = types

class CommonDefineManager(BaseDefineManager):
    def reset(self):
        super().reset()

        self.defined.update({
            LOCAL : {},
            GLOBAL : {},
        })

    def global_define(self, value):
        return self.define(value, GLOBAL)

    def local_define(self, value):
        return self.define(value, LOCAL)

class LuaDefineManager(CommonDefineManager):
    def reset(self):
        super().reset()

        self.default_define_type = GLOBAL

class PythonDefineManager(CommonDefineManager):
    def reset(self):
        super().reset()

        self.default_define_type = LOCAL
        self.defined.update({
            NONLOCAL : {},
        })

    def nonlocal_define(self, value):
        return self.define(value, NONLOCAL)

class LuaBlockEnvManger(LuaDefineManager):
    pass

class PythonBlockEnvManger(PythonDefineManager):
    pass

class BlockBasedNodeVisitor(ast.NodeVisitor):
    # TODO: detect missed value detect! by AST Parser or Lua's Metatable!

    def __init__(self):
        self.reset()

    def reset(self):
        self.indent = 0
        self.special = SpeicalContext()
        self.blocks = []
        self.blocks.append(self.new_blockenv(first=True))

    def new_blockenv(self, **extra):
        raise NotImplementedError

    @property
    def current_block(self):
        if self.blocks:
            return self.blocks[-1]
        else:
            return None

    @contextlib.contextmanager
    def setup_special(self, **extra):
        current_special = self.special

        new_special = self.special.copy()
        new_special.update(extra)
        self.special = new_special

        try:
            yield
        finally:
            self.special = current_special

    @contextlib.contextmanager
    def block(self, **extra):
        block_env = self.new_blockenv(**extra)
        self.enter_block(block_env)
        self.blocks.append(block_env)

        try:
            yield block_env
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

    def not_support_error(self, obj, action="AST"):
        raise TypeError("%s %r are not supported by %s" % (action, obj, type(self).__name__))

DEBUG_LEVEL_DETAIL = 2
DEBUG_LEVEL_SIMPLE = 1
DEBUG_LEVEL_NONE = 0

class BlockBasedCodeGenerator(BlockBasedNodeVisitor):
    def __init__(self, filename=None, debug_level=DEBUG_LEVEL_SIMPLE):
        self.filename = filename
        self.debug_level = debug_level
        super().__init__()

    def reset(self):
        super().reset()
        self.fp = io.StringIO()
        self.lastend = "\n"
        self.lineno = 1
        self.defstack = []

    @contextlib.contextmanager
    def capture_fp(self):
        fp = self.fp
        self.fp = cfp = io.StringIO()

        try:
            yield cfp
        finally:
            self.fp = fp

    def enter_block(self, block_env):
        self.indent += 1
        super().enter_block(block_env)

    def exit_block(self, block_env):
        self.indent -= 1
        super().exit_block(block_env)

    def write_block_start(self, tag):
        is_super_tiny = (self.debug_level == DEBUG_LEVEL_NONE)
        if not self.defstack or self.defstack[-1] != tag:
            if is_super_tiny and self.written_after_se:
                self.fp.write("\n")
                self.written_after_se = False
        self.defstack.append(tag)

    def write_block_end(self, tag):
        is_super_tiny = (self.debug_level == DEBUG_LEVEL_NONE)
        assert self.defstack
        if self.defstack[-1] != tag:
            self.fp.write("\n")
            self.written_after_se = False

        popedtag = self.defstack.pop()
        assert popedtag == tag

    def write(self, *args, sep=' ', end='\n'):
        is_super_tiny = (self.debug_level == DEBUG_LEVEL_NONE)
        fp = self.fp

        if self.lastend.endswith("\n"):
            if not is_super_tiny:
                fp.write(self.indent * self.TAB)
            self.lineno += 1

        self.lastend = end

        if args and args[-1] == ";":
            line = sep.join(args[:-1])
            end = ";" + end
        else:
            line = sep.join(args)

        if is_super_tiny and end.endswith("\n"):
            end = end.rstrip('\n') + " "

        print(line, file=fp, end=end)
        self.written_after_se = True

    def generic_visit(self, node):
        self.not_support_error(node, action="work with")

class LuaCodeGenerator(BlockBasedCodeGenerator):
    TAB_SIZE = 2
    TAB = TAB_SIZE * " "

    def __init__(self, filename=None, debug_level=DEBUG_LEVEL_SIMPLE, short_name=True, short_attribute=True, tiny_line=True):
        super().__init__(filename=filename, debug_level=debug_level)
        self.short_attribute = short_attribute
        self.short_name = short_name
        self.tiny_line = tiny_line

    def reset(self):
        super().reset()
        self.enable_global = False
        self.special_enabled = False
        self.access_for_value_allowed = False
        self.written_after_se = False
        self.quick_object_attrs = False

    def find_unused_var(self):
        # TODO: HELL SLOW MAN
        for i in range(2, 4096):
            try:
                for block in self.blocks:
                    for _, ctx in block.defined.items():
                        for k, v in ctx.items():
                            if v =="_%i" % i:
                                raise StopIteration
            except StopIteration:
                continue
            else:
                return "_%i" % i

    def new_blockenv(self, *, scope=False, first=False, **extra):
        if not scope and not first:
            return self.current_block
        else:
            return PythonBlockEnvManger(parent=self.current_block, **extra)

    def generic_visit(self, node):
        self.not_support_error(node, action="work with")

    def unroll(self, body, mode=None):
        for subnode in body:
            self.write_node(subnode)
            # unroll the write_node(subnode)

    def write_node(self, subnode):
        write = self.write
        with self.hasblock():
            line = self.visit(subnode)
            if line: # must keep it?
                if isinstance(subnode, Expr) and not isinstance(subnode.value, Call):
                    self.write("_T =", line, end=";")
                else:
                    self.write(line, end=";")
                self.write_lineinfo(subnode)
            else:
                self.write_lineinfo(subnode)

    def write_lineinfo(self, subnode):
        if self.debug_level == DEBUG_LEVEL_DETAIL:
            self.write(" -- [LINE %i]" % subnode.lineno)
        else:
            self.write()

    def write_basic_debug_info(self):
        if self.debug_level == DEBUG_LEVEL_DETAIL:
            if self.filename:
                self.write("-- [DEBUG; %s] --" % self.filename)
            else:
                self.write("-- [DEBUG] --")
            self.write()

    def define_short_type(self, define_type):
        if define_type != "local":
            return ""
        else:
            define_type += " "
            return define_type

    def visit_Module(self, node):
        self.reset()
        self.write_basic_debug_info()
        self.write("local _0 = {};")
        block = self.current_block

        if self.enable_global:
            block.set_default_define(GLOBAL)

        self.unroll(node.body)

        return self.fp.getvalue()

    # --- Literals --- #
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

    def visit_Set(self, node):
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
        assert self.vaild_Name(node.id, allow_const=isinstance(node.ctx, Load))
        block = self.current_block

        with self.noblock():
            if node.id.startswith("__PC_"):
                return node.id
            elif node.id.startswith("__") and block.parent is not None:
                raise NotImplementedError("start with __ are not support at now. :P")
            elif node.id in LUA_CONST:
                return node.id
            elif node.id == "...":
                return "..."
            else:
                if self.short_name:
                    for block in self.blocks[::-1]:
                        tvar = block.get_define_value(node.id)
                        if tvar:
                            return tvar

                return node.id

    # -- Expressions -- #
    def visit_Expr(self, node):
        with self.noblock():
            return self.visit(node.value)

    def visit_UnaryOp(self, node):
        with self.noblock():
            value = self.visit(node.operand)
            op = {UAdd:"", USub:"-", Not:"not ", Invert:"~"}[type(node.op)]

            if not op:
                return value
            elif " " in op:
                return "%s%s" % (op, value)
            else:
                return "(%s%s)" % (op, value)

    def visit_BinOp(self, node):
        with self.noblock():
            left = self.visit(node.left)
            right = self.visit(node.right)
            op = {
                Add : "+",
                Sub : "-",
                Mult : "*",
                Div : "/",
                Mod : "%",
                Pow : "^",
            }.get(type(node.op))

            if not op:
                self.not_support_error(node.op, "op")

            return "(%s %s %s)" % (left, op, right)

    def visit_BoolOp(self, node):
        with self.noblock():
            values = list(map(self.visit, node.values))
            op = {
                And : "and",
                Or : "or",
            }[type(node.op)]

            ops = " %s " % op
            return ops.join(values)

    def visit_Compare(self, node):
        check_const = lambda x: isinstance(x, Name) and x.id in (LUA_CONST | PY_CONST)
        with self.noblock():
            assert len(node.ops) == 1
            assert len(node.comparators) == 1

            left = node.left
            op = node.ops[0]
            right = node.comparators[0]

            if isinstance(op, (Is, IsNot)):
                if not (check_const(left) or check_const(right)):
                    # TODO: rawequal
                    self.not_support_error((left, right), "Compare %r with" % op)

                op = {Is : Eq, IsNot : NotEq}[type(op)]()
            elif isinstance(op, (In, NotIn)):
                left = Subscript(
                    value = right,
                    slice = Index(left),
                    ctx = Load(),
                )
                right = Name(LUA_NONE, Load())
                op = {In : NotEq, NotIn : Eq}[type(op)]()

            left, right = map(self.visit, (left, right))
            ops = {
                Eq : "==",
                NotEq : "~=",
                Lt : "<",
                LtE : "<=",
                Gt : ">",
                GtE : ">=",
            }.get(type(op))

            if not ops:
                self.not_support_error(op, "op")

            return "%s %s %s" % (left, ops, right)

    def visit_Call(self, node):
        with self.noblock():
            short_name = self.short_name
            try:
                self.short_name = False
                rawfunc = self.visit(node.func)
            finally:
                self.short_name = short_name

            func = self.visit(node.func)
            args = list(map(self.visit, node.args))

            if rawfunc == "LUA_CODE":
                assert len(node.args) == 1
                assert isinstance(node.args[0], Str)
                return node.args[0].s
            elif rawfunc == "__PC_ECMAXP_ARE_THE_GOD_IN_THIS_WORLD":
                assert len(node.args) == 1
                assert isinstance(node.args[0], Str)
                assert node.args[0].s == "YES"
                self.special_enabled = True
                return ""
            elif not self.special_enabled:
                pass
            elif rawfunc in ("__PC_ECMAXP_SETUP_AUTO_GLOBAL", "__PC_ECMAXP_SETUP_ACCESS_FOR_VALUE", "__PC_ECMAXP_SET_QUICK_OBJECT_ATTRS"):
                assert len(node.args) == 1
                assert isinstance(node.args[0], Name)
                arg = node.args[0].id
                arg = {LUA_TRUE:True, LUA_FLASE:False}[arg]
                if rawfunc == "__PC_ECMAXP_SETUP_AUTO_GLOBAL":
                    block = self.current_block
                    if arg:
                        block.set_default_define(GLOBAL)
                    else:
                        block.set_default_define(LOCAL)
                elif rawfunc == "__PC_ECMAXP_SETUP_ACCESS_FOR_VALUE":
                    self.access_for_value_allowed = arg
                elif rawfunc == "__PC_ECMAXP_SET_QUICK_OBJECT_ATTRS":
                    self.quick_object_attrs = arg
                else:
                    assert False
                return ""
            elif rawfunc == "__PC_ECMAXP_GET_OBJECT_ATTRS":
                assert len(node.args) == 0
                return self.visit(List(list(map(Str, OBJECT_ATTRS)), Load()))
            elif rawfunc == "_" and self.quick_object_attrs:
                assert len(node.args) == 1
                assert isinstance(node.args[0], Str)
                return str(OBJECT_ATTRS.index(node.args[0].s) + 1)

            assert not node.keywords
            assert node.kwargs is None

            if node.starargs:
                block = self.current_block
                vararg = getattr(block, "vararg", None)
                if isinstance(node.starargs, Name) and node.starargs.id == vararg:
                    args.append("...")
                else:
                    args.append("table.unpack(%s)" % (self.visit(node.starargs)))

            args = ", ".join(args)
            return "%s(%s)" % (func, args)

    def visit_arg(self, node):
        # TODO: remove it and put to visit_Call
        with self.noblock():
            return node.arg

    def visit_IfExp(self, node):
        with self.noblock():
            test = self.visit(node.test)
            body = self.visit(node.body)
            orelse = self.visit(node.orelse)

            return "((%s and {%s} or {%s})[1])" % (test, body, orelse)

    def visit_Attribute(self, node):
        with self.noblock():
            value = self.visit(node.value)
            attr = node.attr

            if self.short_attribute:
                if attr in OBJECT_ATTRS:
                    return "%s[%i]" % (value, OBJECT_ATTRS.index(attr) + 1)

            return "%s.%s" % (value, attr)

    # -- Subscripting -- #
    # visit_Subscript must be not direct call from visit, it must different
    #  when assign or see the value??
    def visit_Subscript(self, node):
        with self.noblock():
            name = self.visit(node.value)
            index = self.visit(node.slice)

            return "%s[%s]" % (name, index)

    def visit_Index(self, node):
        with self.noblock():
            return self.visit(node.value)

    # -- Comprehensions -- #

    # -- Statements -- #
    def _get_Name(self, node):
        def nest(x, pure=True):
            if isinstance(x, (Attribute, Subscript)):
                return nest(x.value, pure=False)
            elif isinstance(x, Name):
                return x.id, pure
            return None, False
        return nest(node)

    def visit_AugAssign(self, node):
        import copy
        with self.noblock():
            nt2 = copy.deepcopy(node.target)
            nt2.ctx = Load()

            AssignAST = full_copy_location(ast.Assign(
                targets=[node.target],
                value = ast.BinOp(nt2, node.op, node.value),
            ), node)

            name, _ = self._get_Name(node.target)
            block = self.current_block

            if not block.is_defined(name):
                raise RuntimeError("Name %s are not defined." % name)

        with self.hasblock():
            self.visit(AssignAST)

        raise IsControlFlow

    def visit_Assign(self, node):
        with self.noblock():
            assert len(node.targets) == 1, node.targets
            rawtarget = node.targets[0]

            value = None
            if isinstance(rawtarget, Tuple):
                target = ", ".join(map(self.visit, rawtarget.elts))
                if isinstance(node.value, Tuple):
                    value = ", ".join(map(self.visit, node.value.elts))
                    assert len(rawtarget.elts) == len(node.value.elts)
            else:
                target = self.visit(rawtarget)

            if value is None:
                value = self.visit(node.value)

        define_type = ""
        name, pure = self._get_Name(rawtarget)
        if name is not None and pure:
            block = self.current_block
            if self.short_name and not block.is_defined(name):
                tvar = self.find_unused_var()
                block.define(name, var_info=tvar)
                target = tvar

                define_type = block.default_define_type
            else:
                define_type = block.define_short(name)

        define_hint = self.define_short_type(define_type)

        target2 = target
        block = self.current_block
        if define_type == "local":
            if block.special.inner_class:
                define_hint = ""
                target2 = "_0.%s" % target

        self.write("%s%s = %s" % (define_hint, target2, value), end=";")
        self.write_lineinfo(node)

        raise IsControlFlow

    def visit_Assert(self, node):
        with self.noblock():
            args = [node.test]

            if node.msg is not None:
                args.append(node.msg)

            return self.visit(Call(
                func = Name(type(node).__name__.lower(), Load()),
                args = args,
                keywords = [],
                starargs=None,
                kwargs=None,
            ))

    def visit_Delete(self, node):
        for target in node.targets:
            with self.hasblock():
                assignAST = full_copy_location(
                    Assign([target], Name(LUA_NONE, Load())),
                    node,
                )
                self.visit_Assign(assignAST)

    def visit_Pass(self, node):
        raise IsControlFlow

    # -- Imports -- #
    # Imports are not accepted in cc's lua. use os.loadAPI

    # -- Control flow -- #
    def visit_If(self, node):
        write = self.write

        write("if", self.visit(node.test), "then", end="")
        self.write_lineinfo(node)

        with self.block():
            self.unroll(node.body)

        if node.orelse:
            if len(node.orelse) == 1 and isinstance(node.orelse[0], ast.If):
                write("else", end="")
                with self.hasblock():
                    self.visit_If(node.orelse[0])
                raise IsControlFlow
            else:
                write("else")
                with self.block():
                    self.unroll(node.orelse)
        write("end;")

        raise IsControlFlow

    def _visit_Loop(self, node, *, For_info=None):
        write = self.write
        zrand = random.randint(100000, 999999)
        cont = ""
        brck = ""

        with self.noblock():
            with self.block() as block:
                # LOOP
                if For_info:
                    target, args = For_info
                    write(", ".join(args), "=", target)

                for subnode in node.body:
                    if isinstance(subnode, ast.Continue):
                        cont = "ZCONT_%i" % zrand
                        write("goto", cont)
                    elif isinstance(subnode, ast.Break) and node.orelse:
                        brck = "ZBREAK_%i" % zrand
                        write("goto", brck)
                    else:
                        self.write_node(subnode)

                if cont:
                    write("::", contname, "::", sep="")

            write("end;")

            if node.orelse:
                self.unroll(node.orelse)

            if brck:
                write("::", breakname, "::", sep="")

        raise IsControlFlow

    def visit_For(self, node):
        write = self.write

        block = self.current_block
        with self.setup_special(loop_setup=True, loop_value={}):
            special = self.special
            length = 0

            with self.noblock():
                if isinstance(node.target, Tuple):
                    block = self.current_block
                    #targets = []
                    for subnode in node.target.elts:
                        name, _ = self._get_Name(subnode)
                        if self.short_name and not block.is_defined(name):
                            tvar = self.find_unused_var()
                            block.define(name, LOCAL, var_info=tvar)
                            #targets.append(name)
                        else:
                            if block.define_short(name):
                                pass
                                #targets.append(name)

                    #if targets:
                    #    # FIXME
                    #    write(block.default_define_type, ", ".join(targets), ";")

                    args = tuple(map(self.visit, node.target.elts))
                elif isinstance(node.target, Name):
                    if self.short_name and not block.is_defined(name):
                        tvar = self.find_unused_var()
                        block.define(name, LOCAL, var_info=tvar)
                    else:
                        block.define_short(node.target.id)
                    args = (self.visit(node.target),)
                else:
                    self.not_support_error(node.target)

                args = tuple(args)
                For_info = None
                if self.access_for_value_allowed:
                    target = map(lambda i: "__PC_{}".format(i), range(len(args)))
                    target = ", ".join(target)
                    For_info = target, args
                else:
                    target = ", ".join(args)
                    For_info = "?"

                iter = self.visit(node.iter)
                if For_info == "?":
                    For_info = None

            write("for", target, "in", iter, "do", end="")
            self.write_lineinfo(node)

        self._visit_Loop(node, For_info=For_info)

    def visit_While(self, node):
        write = self.write

        with self.noblock():
            test = self.visit(node.test)

        write("while", test, "do", end="")
        self.write_lineinfo(node)

        self._visit_Loop(node)

    # -- Function and class definitions -- #
    def _visit_Decorators(self, node, name2=None):
        write = self.write

        name2 = name2 if name2 else node.name
        for decorator in node.decorator_list:
            with self.noblock():
                write("%s = %s(%s)" % (name2, self.visit(decorator), name2), ";")

        raise IsControlFlow

    def vaild_Name(self, name, *, allow_const=False):
        if name not in LUA_KEYWORDS:
            return True
        elif allow_const and name not in LUA_KEYWORDS_WITHOUT_CONST:
            return True
        else:
            raise ValueError("Function/Class/Value name can't be lua keyword! (%s)" % name)

    def visit_FunctionDef(self, node):
        write = self.write
        name = node.name
        args = list(map(self.visit, node.args.args))

        vararg = node.args.vararg
        vararg_hint = ""

        if vararg:
            vararg_hint = "%s..." % (args and ", " or "")

        #assert not node.args.vararg
        assert not node.args.kwonlyargs
        assert not node.args.varargannotation
        assert not node.args.kwarg
        assert not node.args.kwargannotation
        assert not node.args.defaults
        assert not node.args.kw_defaults
        assert not node.returns
        assert self.vaild_Name(node.name)

        block = self.current_block

        name2 = name
        if block.special.inner_class:
            assert block.default_define_type == LOCAL
            block.define_short(name)

            define_hint = ""
            name2 = "_0.%s" % name2

            if self.short_attribute and name in OBJECT_ATTRS:
                name2 = ""
                define_hint = "_0[%i] = " % (OBJECT_ATTRS.index(name) + 1)
        elif name == "__build_lua_class__":
            assert block.default_define_type == LOCAL
            define_type = block.define_short(name)
            define_hint = self.define_short_type(define_type)
        else:
            if self.short_name:
                define_hint = self.define_short_type(block.default_define_type)

                name2 = self.visit_Name(Name(name, Store()))
                if name != name2:
                    define_hint = ""
                elif block.default_define_type == LOCAL and not block.is_defined(name):
                    tvar = self.find_unused_var()
                    block.define(name, var_info=tvar)
                    name2 = tvar
            else:
                define_type = block.define_short(name)
                define_hint = self.define_short_type(define_type)

        if name2:
            name2 = " " + name2

        args3 = args
        if self.short_name:
            args3 = []
            with self.block(scope=True) as block:
                for arg in args:
                    tvar = self.find_unused_var()
                    block.define(arg, var_info=tvar)
                    args3.append(tvar)

        rawargs = args
        args2 = ", ".join(args3)
        self.write_block_start("function")
        write("%sfunction%s(%s%s)" % (define_hint, name2, args2, vararg_hint))
        with self.block(scope=True) as block:
            with self.setup_special(inner_class=False):
                # TODO: define _L and use this for local dict.

                for arg, arg2 in zip(rawargs, args3):
                    if not block.is_defined(arg):
                        if arg == arg2:
                            arg2 = None

                        block.define(arg, LOCAL, var_info=arg2)

                if vararg:
                    arg2 = vararg
                    if self.short_name:
                        tvar = self.find_unused_var()
                        block.define(vararg, LOCAL, var_info=tvar)
                        arg2 = tvar
                    else:
                        block.define(vararg, LOCAL)

                    write("local %s = {...};" % (arg2,))
                    block.vararg = vararg

                with self.capture_fp() as cfp:
                    self.unroll(node.body)

                local_defined = []
                if False: # LOOP
                    if value.startswith("loop") and key in block.local_defined:
                        if key not in local_defined:
                            local_defined.append(key)

                if local_defined:
                    write("local %s;" % (", ".join(local_defined),))

                self.fp.write(cfp.getvalue())

        write("end;")

        with self.hasblock():
            self._visit_Decorators(node, name2=name2)

        self.write_block_end("function")
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

        # TODO: don't use unpack in here? (*args)

        class LambdaVarargTransfomer(ast.NodeTransformer):
            def visit_Name(self, node):
                if node.id == vararg:
                    return List([Name("...", Load())], Store()) # FIXME
                return node

        if vararg:
            transformer = LambdaVarargTransfomer()
            node.body = transformer.visit(node.body)

        args = ", ".join(args)
        result = "(function(%s) return " % args
        with self.noblock():
            result += self.visit(node.body)
        result += "; end)"

        return result

    def visit_Return(self, node):
        write = self.write
        if node.value is None:
            write("return;")
        else:
            write("return", self.visit(node.value), ";")

        raise IsControlFlow

    def visit_Global(self, node):
        block = self.current_block
        for name in node.names:
            block.global_define(name)

        # self.write("-- global %s" % ", ".join(node.names))
        raise IsControlFlow

    def visit_Nonlocal(self, node):
        block = self.current_block
        for name in node.names:
            block.nonlocal_define(name)

        # self.write("-- nonlocal %s" % ", ".join(node.names))
        raise IsControlFlow

    # visit_Continue and visit_Break are needed. (for, if?)

    def visit_ClassDef(self, node):
        write = self.write

        assert not node.starargs
        assert not node.kwargs
        assert self.vaild_Name(node.name)

        metatable = None
        for keyword in node.keywords:
            key = keyword.arg
            value = keyword.value
            if key == "metatable":
                metatable = self.visit(value)
            else:
                raise NotImplementedError("PEP-3115 are not supported in %s" % type(self).__name__)

        name = node.name
        name2 = name
        bases = node.bases
        block = self.current_block

        if self.short_name:
            name2 = self.visit_Name(Name(name, Store()))
            if name != name2:
                define_hint = ""
            elif block.default_define_type == LOCAL and not block.is_defined(name):
                define_hint = self.define_short_type(block.default_define_type)
                tvar = self.find_unused_var()
                block.define(name, var_info=tvar)
                name2 = tvar
            else:
                define_type = block.define_short(name)
                define_hint = self.define_short_type(define_type)
        else:
            define_type = block.define_short(name)
            define_hint = self.define_short_type(define_type)

        bases = []
        for base in node.bases:
            bases.append(self.visit(base))

        self.write_block_start("class")
        write("%s%s = nil" % (define_hint, name2), ";")
        write("_0 = __build_lua_class__(%s, {%s})" % (repr(name), ", ".join(bases)), ";")
        with self.block(scope=True) as block:
            block.special.inner_class = True
            for subnode in node.body:
                self.write_node(subnode)

        if metatable:
            write("setmetatable(_0, %s)" % (name2, metatable), ";")

        with self.hasblock():
            self._visit_Decorators(node, name2="_0")

        write("%s = _0" % (name2,), ";")
        self.write_block_end("class")
        raise IsControlFlow

def lua_compile(code, debug=DEBUG_LEVEL_SIMPLE, filename_hint=None):
    if hasattr(code, "read"):
        code = code.read()

    codetree = ast.parse(code, mode="exec")
    generator = LuaCodeGenerator(filename=filename_hint, debug_level=debug)
    code = generator.visit(codetree)

    if debug == DEBUG_LEVEL_NONE:
        code = compress_lua_code(code)

    return code

class ExecuteLite_LuaException(Exception):
    pass

def execute_lite(runfile, cwd=None):
    if os.sep in os.path.normpath(runfile):
        # FIXME LATER!
        raise RuntimeError("Can't guess lua pattern of error")

    Lua_TB_Start = "stack traceback:"
    Py_TB_Format = [
        # 0, Traceback (most recent call last):
        'Traceback (most recent call last):',

        # 1,   File "something.py"
        '  File "{}"',
        # HAVE_DETAIL
        '  File "{}", {}',
        # HAVE_LINE
        '  File "{}", line {}',
        # HAVE_LINE + HAVE_DETAIL
        '  File "{}", line {}, {}',

        # -2,    raise Exception("something")
        '    {}',

        # -1, Exception: something
        '{}: {}',
    ]

    BASIC = 1
    HAVE_LINE = 2
    HAVE_DETAIL = 1

    finfo = {}
    def init_fileinfo(filename):
        nonlocal cwd

        if filename not in finfo:
            flines = [None]
            finfo[filename] = flines

            realno = None

            cwd = cwd or os.getcwd()
            with open(os.path.join(cwd, filename), 'r') as fp:
                for line in fp:
                    line = line.rstrip('\r\n')
                    if "-- [LINE " in line:
                        a, b, c = line.rpartition("-- [LINE ")
                        d, e, f = c.partition("]")
                        assert a and b and e and not f
                        realno = int(d)
                    elif line.startswith("-- [DEBUG; "): # ] --
                        a, b, c = line.partition("-- [DEBUG; ")
                        d, e, f = c.partition("] --")
                        assert not a and b and c and e and not f
                        flines[0] = os.path.abspath(os.path.join(cwd, d))

                    flines.append(realno)

    def get_from_filename(filename):
        return finfo[filename][0]

    def get_lineno(filename, lineno):
        return finfo[filename][lineno]

    def parse_tb(line, is_first=False, ignore_realno=False):
        trace, sep, detail = line.partition(": ")
        filename, have_lineno, lineno = trace.partition(":")
        if is_first and trace == "[C]" and detail == "?":
            return

        if not have_lineno:
            fmt = Py_TB_Format[BASIC + bool(detail)]
            print(fmt.format(filename, detail))
            return

        filename, sep, lineno = trace.partition(":")
        lineno = int(lineno)

        if filename == runfile:
            init_fileinfo(filename)
            fromfile = get_from_filename(filename)

            if fromfile:
                realno = get_lineno(filename, lineno)

                if realno and not ignore_realno:
                    line = linecache.getline(fromfile, realno)
                    line = line.strip()

                    if line.endswith("#--[DEBUG; ERROR POINT]--#"):
                        return False

                    fmt = Py_TB_Format[BASIC + HAVE_LINE + bool(detail)]
                    print(fmt.format(fromfile, realno, detail))

                    fmt = Py_TB_Format[-2]
                    print(fmt.format(line))
                    return

        fmt = Py_TB_Format[BASIC + HAVE_LINE + bool(detail)]
        print(fmt.format(filename, lineno, detail))

    process = subprocess.Popen(
        [LUA_EXECUTE, runfile],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )

    stdout, stderr = map(bytes.decode, process.communicate())

    stdout = stdout.rstrip()
    if stdout:
        print(stdout)

    tbline = None
    stderr = stderr.rstrip()

    if stderr:
        print()
        tbs = []

        for line in stderr.splitlines():
            if tbline is None:
                tbline = line
                continue

            if line == Lua_TB_Start:
                print(Py_TB_Format[0])
            elif line.startswith("\t"):
                tbs.append(line.lstrip("\t"))
            else:
                print(line)

        for no, tb in enumerate(reversed(tbs)):
            if parse_tb(tb, is_first=(not no)) is False:
                break

        detail = "Unknown STDERR are captured."

        if tbs:
            tb = tbline.partition(": ")[2]
            tb, sep, detail = tb.partition(": ")
            # parse_tb(tb)

            fmt = Py_TB_Format[-1]
            print(fmt.format("E", detail))
        elif tbline:
            tb = tbline.partition(": ")[2]
            tb, sep, detail = tb.partition(": ")
            assert sep, (tb, sep, detail)
            parse_tb(tb, ignore_realno=True)
            filename, sep, lineno = tb.partition(":")
            lineno = int(lineno)
            assert sep

            line = linecache.getline(filename, lineno)

            fmt = Py_TB_Format[-2]
            print(fmt.format(line))

            fmt = Py_TB_Format[-1]
            print(fmt.format("SyntexError", detail))

        raise ExecuteLite_LuaException(detail)

def compile_and_run_py_API():
    filename_api = "py_API"
    filename_api_py = filename_api + ".py"
    filename_api_lua = filename_api + ".lua"
    filename_rel = "py"

    with open(filename_api_py) as fp:
        code = fp.read()

    compiled = lua_compile(code, debug=DEBUG_LEVEL_DETAIL, filename_hint=filename_api_py)
    #print("Success compiled with size:", len(compiled))

    with open(filename_api_lua, "w") as fp:
        fp.write(compiled)

    if os.getlogin() == "EcmaXp":
        # Only for me :D
        if os.path.exists(r"X:\Data\Workspace\newlua\src"):
            with open(r"X:\Data\Workspace\newlua\src\py_API.lua", "w") as fp:
                fp.write(compiled)

        if os.path.exists(r"C:\Users\EcmaXp\AppData\Roaming\.ccdesk\computer\0"):
            with open(r"C:\Users\EcmaXp\AppData\Roaming\.ccdesk\computer\0\py", "w") as fp:
                fp.write(compiled)

    try:
        execute_lite(filename_api_lua)
    except ExecuteLite_LuaException:
        pass
    else:
        lite_compiled = lua_compile(code, debug=DEBUG_LEVEL_SIMPLE) # DEBUG_LEVEL_NONE
        with open(filename_rel + "_latest", "w") as fp:
            fp.write(lite_compiled)

def compress_lua_code(text):
    fp = io.StringIO()
    text = "".join(line.strip() + '\n' for line in text.splitlines())

    word = []
    get = iter(text).__next__
    def write(): fp.write("".join(word)); word[:] = []
    isidentifier = lambda x: x.isidentifier() or x.isalnum()
    try:
        while True:
            ch = get()
            if ch == " ":
                continue
            elif not isidentifier(ch) and ch != " ":
                word += ch
                write()
                continue
            else:
                while isidentifier(ch):
                    word += ch
                    ch = get()

                if ch == " ":
                    ch = get()
                    if isidentifier(ch):
                        word += " " + ch
                        write()
                    else:
                        word += ch
                else:
                    word += ch
    except StopIteration:
        pass

    return fp.getvalue()

def main():
    return compile_and_run_py_API()

    print(compress_lua_code(lua_compile("""\
# Place code in here?
class test():
    def __repr__(self):
        pass

test.__repr__()
""")), end="")

if __name__ == '__main__':
    main()
