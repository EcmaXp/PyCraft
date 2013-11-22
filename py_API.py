if pyscripter: exit(__import__('pc').main())
### THE HACK FOR RUN py-API.py in pyscripts.
__PC_ECMAXP_ARE_THE_GOD_IN_THIS_WORLD("YES")

global lua
lua = {}
lua.len = lambda obj: LUA_CODE("#obj")
lua.concat = lambda *args: table.concat(args)
for key, value in pairs(_G):
    lua[key] = value

PY_OBJ_TAG = "#"
LUA_OBJ_TAG = "@"

TAG = "[PY]"
ObjLastID = 0
inited = False

__PCEX__ = "__PCEX__"
builtins = "builtins"

## This table are weaktable.
ObjID = setmetatable({}, {"__mode":"k"})
ObjValue = setmetatable({}, {"__mode":"k"})
Obj_FromID = setmetatable({}, {"__mode":"v"})
IsBuiltinTypes = setmetatable({}, {"__mode":"k"})
## must cleaned after collectgarbage()

builtin_methods = __PC_ECMAXP_GET_OBJECT_ATTRS()
builtin_methods_rev = {}
for k, v in pairs(builtin_methods):
    builtin_methods_rev[v] = k

assert builtin_methods[42] == '__rshift__'
assert builtin_methods_rev["__pos__"] == 72
error = nil

def is_float(num):
    if lua.type(num) != "number":
        error("This is not number", 2)

    return math.floor(num) != num

def is_pyobj(obj):
    return ObjID[obj] is not nil

def PObj(obj):
    if is_pyobj(obj):
        return obj
    else:
        return LuaObject(obj)

def LObj(obj):
    if is_pyobj(obj):
        return _OP__Lua__(obj)
    else:
        return obj

def require_pyobj(*objs):
    for idx, obj in pairs(objs):
        if not is_pyobj(obj):
            lua.print(lua.type(obj), obj)
            error("Require python object.")

    return true

def register_pyobj(obj):
    global ObjLastID
    ObjLastID += 1
    obj_id = ObjLastID

    ObjID[obj] = obj_id
    Obj_FromID[obj_id] = obj
    return obj

def error(msg, level):
    if level is nil:
        level = 1

    if is_pyobj(msg):
        msg = LObj(msg)

    level += 1
    lua.error(lua.concat(TAG, " ", tostring(msg)), level)

def require_args(*args):
    for key, value in pairs(args):
        if value is nil:
            error("SystemError: Not Enough Item")

    return True

def nonrequire_args(*args):
    for key, value in pairs(args):
        if value is not nil:
            error("SystemError: Not Enough Item")

    return True

def is_float(num):
    if lua.type(num) != "number":
        error("This is not number", 2)

    return math.floor(num) != num

def setup_base_class(cls):
    rawset(cls, __PCEX__, nil)

    pcex = {}
    for k, v in pairs(cls):
        idx = builtin_methods_rev[k]
        if idx is not nil:
            pcex[idx] = v

    rawset(cls, __PCEX__, pcex)
    IsBuiltinTypes[cls] = false
    register_pyobj(cls)

    return cls

def setup_basic_class(cls):
    setup_base_class(cls)
    setmetatable(cls, type)

    return cls

def setup_hide_class(cls):
    IsBuiltinTypes[cls] = nil
    return cls

def register_builtins_class(cls):
    idx = 1
    mro = {}

    bases = rawget(cls, "__bases__")
    if bases is not nil:
        LUA_CODE("for i = #bases, 1, -1 do --")
        if true:
            base = bases[i]
            if IsBuiltinTypes[base] is not nil:
                mro[idx] = base
                idx += 1
        LUA_CODE("end")

    mro[idx] = cls
    idx += 1

    if cls != object:
        mro[idx] = object
        idx += 1

    rawset(cls, "__bases__", nil)
    rawset(cls, "__name__", str(rawget(cls, "__name__")))
    rawset(cls, "__module__", str("builtins"))
    rawset(cls, "__mro__", tuple(mro))

    IsBuiltinTypes[cls] = true
    return cls

def Fail_OP(a, ax):
    error(lua.concat(LObj(repr(a)), " are not support ", builtin_methods[ax]))

def Fail_OP_Raw(a, raw_ax):
    error(lua.concat(LObj(repr(a)), " are not support ", raw_ax))

def Fail_OP_Math_Raw(a, b, raw_ax):
    error(lua.concat("Not support ", LObj(repr(a)), ' ', raw_ax, ' ', LObj(repr(b))))

def Fail_OP_Math(a, b, ax, extra):
    if extra is nil:
        extra = ""
    else:
        extra = lua.concat(" ", extra)

    error(lua.concat("Not support ", LObj(repr(a)), ' ', builtin_methods[ax], ' ', LObj(repr(b)), extra))

def Fail_OP_Math_Pow(a, b, ax, c):
    extra = ""
    if c:
        extra = lua.concat("% ", LObj(repr(c)))

    Fail_OP_Math(a, b, ax, c)

def OP_Call(ax):
    def func(a, *args):
        assert require_pyobj(a)
        f = rawget(getmetatable(a), __PCEX__)[ax]
        if f:
            return f(a, *args)

        Fail_OP(a, ax)
    return func

def OP_Math2(ax, bx):
    def func(a, b):
        assert require_pyobj(a, b)
        am = rawget(getmetatable(a), __PCEX__)
        bm = rawget(getmetatable(b), __PCEX__)

        f = am[ax]
        if f:
            ret = f(a, b)
            if ret != NotImplemented: return ret

        f = bm[bx]
        if f:
            ret = f(b, a)
            if ret != NotImplemented: return ret

        Fail_OP_Math(a, b, ax)

    return func

def OP_Math3(cx, ax, bx): # cx is first.
    def func(a, b):
        assert require_pyobj(a, b)
        am = rawget(getmetatable(a), __PCEX__)
        bm = rawget(getmetatable(b), __PCEX__)
        is_n = isinstance(a, int) == True or isinstance(b, float) == True

        if is_n:
            f = am[ax]
            if f:
                ret = f(a, b)
                if ret != NotImplemented: return ret

        f = am[cx]
        if f:
            ret = f(a, b)
            if ret != NotImplemented: return ret

        # OP_Math2
        if not is_n:
            f = am[ax]
            if f:
                ret = f(a, b)
                if ret != NotImplemented: return ret

        f = bm[bx]
        if f:
            ret = f(b, a)
            if ret != NotImplemented: return ret

        Fail_OP_Math(a, b, cx)

    return func

def OP_Math2_Pow(ax, bx):
    def func(a, b, c):
        assert require_pyobj(a, b)
        assert require_pyobj(c) or c is nil
        am = rawget(getmetatable(a), __PCEX__)
        bm = rawget(getmetatable(b), __PCEX__)

        f = am[ax]
        if f:
            ret = f(a, b, c)
            if ret != NotImplemented: return ret

        if c is not nil:
            # http://docs.python.org/3.3/reference/datamodel.html
            # Note. that ternary pow() will not try calling __rpow__()
            #       (the coercion rules would become too complicated).

            f = bm[bx]
            if f:
                ret = f(b, a)
                if ret != NotImplemented: return ret

        Fail_OP_Math_Pow(a, b, ax, c)

    return func

def OP_Math3_Pow(cx, ax, bx):
    def func(a, b, c):
        assert require_pyobj(a, b)
        assert require_pyobj(c) or c is nil
        am = rawget(getmetatable(a), __PCEX__)
        bm = rawget(getmetatable(b), __PCEX__)

        f = am[cx]
        if f:
            ret = f(a, b, c)
            if ret != NotImplemented: return ret

        f = am[ax]
        if f:
            ret = f(a, b, c)
            if ret != NotImplemented: return ret

        if c is not nil:
            f = bm[bx]
            if f:
                ret = f(b, a)
                if ret != NotImplemented: return ret

        Fail_OP_Math_Pow(a, b, ax, c)

    return func

global _OP__Is__, _OP__IsNot__
def  _OP__Is__(a, b):
    require_pyobj(a, b)
    return ObjID[a] == ObjID[b]

def _OP__IsNot__(a, b):
    return not _OP__Is__(a, b)

def _(name): return builtin_methods_rev[name]
__PC_ECMAXP_SETUP_AUTO_GLOBAL(true)
## Basic Call (Part A)
_OP__New__ = OP_Call(_('__new__'))
_OP__Init__ = OP_Call(_('__init__'))
_OP__Del__ = OP_Call(_('__del__'))
_OP__Repr__ = OP_Call(_('__repr__'))
_OP__Str__ = OP_Call(_('__str__'))
_OP__Bytes__ = OP_Call(_('__bytes__'))
_OP__Format__ = OP_Call(_('__format__'))
_OP__Lt__ = OP_Call(_('__lt__'))
_OP__Le__ = OP_Call(_('__le__'))
_OP__Eq__ = OP_Call(_('__eq__'))
_OP__Ne__ = OP_Call(_('__ne__'))
_OP__Gt__ = OP_Call(_('__gt__'))
_OP__Ge__ = OP_Call(_('__ge__'))
_OP__Hash__ = OP_Call(_('__hash__'))
_OP__Bool__ = OP_Call(_('__bool__'))
_OP__Getattr__ = OP_Call(_('__getattr__'))
_OP__Getattribute__ = OP_Call(_('__getattribute__'))
_OP__Setattr__ = OP_Call(_('__setattr__'))
_OP__Delattr__ = OP_Call(_('__delattr__'))
_OP__Dir__ = OP_Call(_('__dir__'))
_OP__Get__ = OP_Call(_('__get__'))
_OP__Set__ = OP_Call(_('__set__'))
_OP__Delete__ = OP_Call(_('__delete__'))
_OP__Slots__ = OP_Call(_('__slots__'))
_OP__Call__ = OP_Call(_('__call__'))
_OP__Len__ = OP_Call(_('__len__'))
_OP__Getitem__ = OP_Call(_('__getitem__'))
_OP__Setitem__ = OP_Call(_('__setitem__'))
_OP__Delitem__ = OP_Call(_('__delitem__'))
_OP__Iter__ = OP_Call(_('__iter__'))
_OP__Reversed__ = OP_Call(_('__reversed__'))
_OP__Contains__ = OP_Call(_('__contains__'))

## Math Operation (A * B)
_OP__Add__ = OP_Math2(_('__add__'), _('__radd__'))
_OP__Sub__ = OP_Math2(_('__sub__'), _('__rsub__'))
_OP__Mul__ = OP_Math2(_('__mul__'), _('__rmul__'))
_OP__Truediv__ = OP_Math2(_('__truediv__'), _('__rtruediv__'))
_OP__Floordiv__ = OP_Math2(_('__floordiv__'), _('__rfloordiv__'))
_OP__Mod__ = OP_Math2(_('__mod__'), _('__rmod__'))
_OP__Divmod__ = OP_Math2(_('__divmod__'), _('__rdivmod__'))
_OP__Pow__ = OP_Math2_Pow(_('__pow__'), _('__rpow__'))
_OP__Lshift__ = OP_Math2(_('__lshift__'), _('__rlshift__'))
_OP__Rshift__ = OP_Math2(_('__rshift__'), _('__rrshift__'))
_OP__And__ = OP_Math2(_('__and__'), _('__rand__'))
_OP__Xor__ = OP_Math2(_('__xor__'), _('__rxor__'))
_OP__Or__ = OP_Math2(_('__or__'), _('__ror__'))

## Math Operation (A *= B)
_OP__Iadd__ = OP_Math3(_('__iadd__'), _('__add__'), _('__radd__'))
_OP__Isub__ = OP_Math3(_('__isub__'), _('__sub__'), _('__rsub__'))
_OP__Imul__ = OP_Math3(_('__imul__'), _('__mul__'), _('__rmul__'))
_OP__Itruediv__ = OP_Math3(_('__itruediv__'), _('__truediv__'), _('__rtruediv__'))
_OP__Ifloordiv__ = OP_Math3(_('__ifloordiv__'), _('__floordiv__'), _('__rfloordiv__'))
_OP__Imod__ = OP_Math3(_('__imod__'), _('__mod__'), _('__rmod__'))
_OP__Ipow__ = OP_Math3_Pow(_('__ipow__'), _('__pow__'), _('__rpow__'))
_OP__Ilshift__ = OP_Math3(_('__ilshift__'), _('__lshift__'), _('__rlshift__'))
_OP__Irshift__ = OP_Math3(_('__irshift__'), _('__rshift__'), _('__rrshift__'))
_OP__Iand__ = OP_Math3(_('__iand__'), _('__and__'), _('__rand__'))
_OP__Ixor__ = OP_Math3(_('__ixor__'), _('__xor__'), _('__rxor__'))
_OP__Ior__ = OP_Math3(_('__ior__'), _('__or__'), _('__ror__'))

## Basic Call (Part B)
_OP__Neg__ = OP_Call(_('__neg__'))
_OP__Pos__ = OP_Call(_('__pos__'))
_OP__Abs__ = OP_Call(_('__abs__'))
_OP__Invert__ = OP_Call(_('__invert__'))
_OP__Complex__ = OP_Call(_('__complex__'))
_OP__Int__ = OP_Call(_('__int__'))
_OP__Float__ = OP_Call(_('__float__'))
_OP__Round__ = OP_Call(_('__round__'))
_OP__Index__ = OP_Call(_('__index__'))
_OP__Enter__ = OP_Call(_('__enter__'))
_OP__Exit__ = OP_Call(_('__exit__'))

## Extra Call
_OP__Lua__ = OP_Call(_('__lua__'))

## Builtins
def repr(obj):
    if is_pyobj(obj):
        return _OP__Repr__(obj)
    else:
        return lua.concat(LUA_OBJ_TAG, "(", tostring(obj), ")")

def print(*args):
    write = lua.io.write
    sep = " "

    for _, arg in pairs(args):
        if is_pyobj(arg):
            arg = str(arg)
        else:
            arg = repr(arg)

        arg = LObj(arg)
        write(arg)
        write(sep)

    write("\n")

def isinstance(obj, targets):
    require_pyobj(obj)

    cls = type(obj)
    mro = cls.mro()
    assert type(mro) == tuple

    for _, supercls in pairs(ObjValue[mro]):
        require_pyobj(supercls)
        if supercls == targets:
            return True

    return False

def issubclass(cls, targets):
    require_pyobj(obj)

    if type(cls) != type:
        error("issubclass() arg 1 must be a class")

    mro = cls.mro()
    assert type(mro) == tuple

    for _, supercls in pairs(ObjValue[mro]):
        require_pyobj(supercls)
        if supercls == targets:
            return True

    return False

def id(obj):
    if is_pyobj(obj):
        return int(ObjID[obj])

    Fail_OP_Raw(obj, "__id!")

def len(obj):
    return _OP__Len__(obj)

__PC_ECMAXP_SETUP_AUTO_GLOBAL(false)
_ = nil
## end?

global object
@setup_base_class
class object():
    def __init__(self):
        pass

    def __call(self, *args):
        return _OP__Call__(self, *args)

    def __index(self, key):
        return _OP__Getattribute__(self, key)

    def __newindex(self, key, value):
        return _OP__Setattr__(self, key, value)

    def __tostring(self):
        return lua.concat(PY_OBJ_TAG, "(", LObj(repr(self)), ")")

    def __new__(cls, *args):
        instance = {}
        instance = register_pyobj(instance)
        lua.setmetatable(instance, cls)
        _OP__Init__(instance, *args)

        return instance

    def __getattribute__(self, k):
        v = rawget(self, k)
        if v is not nil:
            return v

        mt = getmetatable(self)
        v = rawget(mt, k)
        if v is not nil:
            if lua.type(v) == "function":
                return lambda *args: v(self, *args)
            else:
                return v

        error(lua.concat("Not found '", k, "' attribute."))

    def __setattr__(self, key, value):
        if IsBuiltinTypes[type(self)] and inited:
            error("TypeError: can't set attributes of built-in/extension type 'object'")

        # TODO: Add PCEX Support!
        rawset(self, key, value)

    def __str__(self):
        return _OP__Repr__(self)

    def __repr__(self):
        mtable = getmetatable(self)
        return str(lua.concat("<object ", LObj(mtable.__name__), " at ", LObj(id(self)),">"))

global type
@setup_base_class
class type(object):
    def __call__(cls, *args):
        instance = cls.__new__(cls, *args)
        register_pyobj(instance)

        return instance

    def __repr__(cls):
        return str(lua.concat("<class '", LObj(cls.__name__), "'>"))

    def mro(cls):
        return cls.__mro__

@setup_base_class
class ptype(type):
    def __call__(cls, *args):
        if lua.len(args) == 1:
            require_pyobj(args[1])
            return getmetatable(args[1])
        elif lua.len(args) == 3:
            pass
        else:
            error("Unexcepted arguments.")

setmetatable(object, type)
setmetatable(type, ptype)
setmetatable(ptype, ptype)

@setup_basic_class
class BaseException(object):
    args = nil

    def __new__(cls, *args):
        param = tuple(args)
        instance = object.__new__(cls)
        rawset(instance, "args", param)
        _OP__Init__(instance, param)
        return instance

    def __str__(self):
        length = LObj(len(self.args))
        if length == 0:
            return str("")
        elif length == 1:
            return str(_OP__Getitem__(self.args, int(0)))

    def __repr__(self):
        excname = LObj(type(self).__name__)
        return lua.concat(excname, repr(self.args))

    def __lua__(self):
        excname = LObj(type(self).__name__)
        value = str(self)

        if LObj(len(value)) > 0:
            return lua.concat(excname, ": ", LObj(value))
        else:
            return lua.concat(excname)

@setup_basic_class
class Exception(BaseException):
    pass

@setup_basic_class
class BuiltinConstType(object):
    def __new__(cls, *args):
        if not inited:
            instance = object.__new__(cls, *args)
            _OP__Init__(instance, *args)
            return instance

        return cls._get_singleton()

    def _get_singleton(cls):
        error("Not defined.")

@setup_basic_class
class NotImplementedType(BuiltinConstType):
    def _get_singleton(cls):
        return NotImplemented

    def __repr__(self):
        return str("NotImplemented")

@setup_basic_class
class EllipsisType(BuiltinConstType):
    def _get_singleton(self):
        return Ellipsis

    def __repr__(self):
        return str("Ellipsis")

@setup_basic_class
class NoneType(BuiltinConstType):
    def _get_singleton(cls):
        return None

    def __repr__(self):
        return str("None")

@setup_basic_class
@setup_hide_class
class LuaObject(object):
    # This is hidden, and core of calc.
    LuaObject = true
    # isinstance are need.

    def __init__(self, obj):
        mtable = getmetatable(obj)
        if mtable and rawget(mtable, "LuaObject"):
            obj = LObj(obj)

        ObjValue[self] = obj

    def __str__(self):
        return str(_OP__Repr__(self))

    def __repr__(self):
        return str(tostring(ObjValue[self]))

    def __lua__(self):
        return ObjValue[self]

@setup_basic_class
@setup_hide_class
class LuaValueOnlySequance(LuaObject):
    def __init__(self, value):
        if is_pyobj(value):
            self.check_type(value)

        ObjValue[self] = value

    def check_type(self, value):
        if type(value) == "table": pass
        elif value[lua.len(value)] is nil: pass
        elif value[1] is nil: pass
        elif value[0] is not nil: pass
        else:
            return true

        return false

    def make_repr(self, s, e):
        ret = []
        idx = 1

        sep = ""
        ret[idx] = s; idx += 1
        for k,v in pairs(ObjValue[self]):
            ret[idx] = sep; idx += 1
            ret[idx] = LObj(repr(v)); idx += 1
            sep = ", "

        ret[idx] = e; idx += 1

        return table.concat(ret)

global list
@setup_basic_class
class list(LuaValueOnlySequance):
    def __repr__(self):
        return self.make_repr("[", "]")

    def __setattr__(self, key, value):
        error("Not allowed")

global tuple
@setup_basic_class
class tuple(LuaValueOnlySequance):
    def __repr__(self):
        return self.make_repr("(", ")")

    def __setattr__(self, key, value):
        error("Not allowed")

    def __len__(self):
        return int(lua.len(ObjValue[self]))

    def __getitem__(self, x):
        assert is_pyobj(x)
        if isinstance(x, int):
            return ObjValue[self][LObj(x) + 1]

        error("Not support unknown type.")

global str
@setup_basic_class
class str(LuaObject):
    def __init__(self, value):
        if is_pyobj(value):
            value = _OP__Str__(value)
            value = LObj(value)

        ObjValue[self] = value

    def __str__(self):
        return self

    def __repr__(self):
        return str(lua.concat("'", ObjValue[self], "'"))

    def __len__(self):
        return int(lua.len(ObjValue[self]))

global bool
@setup_basic_class
class bool(LuaObject):
    def __new__(cls, value):
        if not inited:
            instance = object.__new__(cls)
            ObjValue[instance] = value
            return instance

        if is_pyobj(value):
            value = _OP__Bool__(value)
            # check type
        else:
            value = value and true or false

        if value == true:
            return True
        elif value == false:
            return False
        elif is_pyobj(value) and type(value) == bool:
            return value

        error("__Bool__ are returned unknown value.")

    def __repr__(self):
        value = ObjValue[self]
        if value == true:
            return str("True")
        elif value == false:
            return str("False")

global int
@setup_basic_class
class int(LuaObject):
    def __add__(self, other):
        # TODO: We must use pattern for something.

        return int(ObjValue[self] + ObjValue[other])

global dict
@setup_basic_class
class dict(LuaObject):
    pass

## inital Code
def inital():
    # register_builtins_class do support object class register. (no parent)
    for cls, value in pairs(IsBuiltinTypes):
        assert value is false
        register_builtins_class(cls)

    _M["NotImplemented"] = NotImplementedType()
    _M["Ellipsis"] = EllipsisType()
    _M["None"] = NoneType()
    _M["True"] = bool(true)
    _M["False"] = bool(false)

    return true

inited = inital()
##

##

x = list({int(1), int(2), int(3)})
y = int(5)
z = int(7)

print(x)
print(True is nil)
print(True)
print(issubclass(int, object))
print(int.mro())
print(_OP__Add__(y, z))
error(Exception(str("test")))