if pyscripter: exit(__import__('pc').main())
### THE HACK FOR RUN py-API.py in pyscripts.
__PC_ECMAXP_ARE_THE_GOD_IN_THIS_WORLD("YES")
__PC_ECMAXP_SETUP_PCEX(true) # __PCEX__ YES!

global lua

lua = {}
for key, value in pairs(_G):
    lua[key] = value

builtins = "builtins"
TAG = '[PY]'
OBJ_ID = 0

ObjectID_FromRef = setmetatable({}, {"__mode":"k"})
ObjectRef_FromID = setmetatable({}, {"__mode":"v"})

__PCEX__ = "__PCEX__"
methods = GET_METHODS()

def lua_len(obj):
    return LUA_CODE("#obj")

def lua_concat(*args):
    r = ""
    for _, x in pairs(args):
        x = tostring(x)
        r = LUA_CODE("r..x")

    return r

lua.len = lua_len
lua.concat = lua_concat

def is_float(num):
    if lua.type(num) != "number":
        error("This is not number", 2)

    return math.floor(num) != num

def error(msg, level):
    if level is nil:
        level = 1

    level += 1
    lua.error(lua.concat(TAG, " ", msg), level)

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

def is_pyobj(obj):
    mtable = lua.getmetatable(obj)
    return mtable and rawget(mtable, TAG) == TAG or false

def to_pyobj(obj):
    if is_pyobj(obj):
        return obj
    else:
        return LuaObject(obj)

##        objtype = lua.type(obj)
##        if objtype == "number":
##            if not is_float(obj):
##                return int(obj)
##            else:
##                return float(obj)
##        elif objtype == "string":
##            return str(obj)
##        else:
##            return LuaObject(obj)

def to_luaobj(obj):
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
    global OBJ_ID
    OBJ_ID += 1
    obj_id = OBJ_ID

    ObjectID_FromRef[obj] = obj_id
    ObjectRef_FromID[obj_id] = obj
    return obj

def build_builtins_cls_bases(cls, *bases):
    mro = {}
    idx = 1
    LUA_CODE("for i = #bases, 1, -1 do --")
    if true:
        base = bases[i]
        mro[idx] = base
        idx += 1
    LUA_CODE("end")

    mro[idx] = cls
    rawset(cls, "__module__", str("builtins"))
    rawset(cls, "__mro__", tuple(mro))
    return cls

def Fail_OP(a, ax):
    error(lua.concat(to_luaobj(repr(a)), " are not support ", methods[ax]))

def Fail_OP_Raw(a, raw_ax):
    error(lua.concat(to_luaobj(repr(a)), " are not support ", raw_ax))

def Fail_OP_Math_Raw(a, b, raw_ax):
    error(lua.concat("Not support ", to_luaobj(repr(a)), ' ', raw_ax, ' ', to_luaobj(repr(b))))

def Fail_OP_Math(a, b, ax, extra):
    if extra is nil:
        extra = ""
    else:
        extra = lua.concat(" ", extra)

    error(lua.concat("Not support ", to_luaobj(repr(a)), ' ', methods[ax], ' ', to_luaobj(repr(b)), extra))

def Fail_OP_Math_Pow(a, b, ax, c):
    extra = ""
    if c:
        extra = lua.concat("% ", to_luaobj(repr(c)))

    Fail_OP_Math(a, b, ax, c)

global repr
def repr(obj):
    if is_pyobj(obj):
        return _OP__Repr__(obj)
    else:
        return lua.concat("@(", tostring(obj), ")")

global print
def print(*args):
    write = lua.io.write
    sep = " "

    for _, arg in pairs(args):
        if is_pyobj(arg):
            arg = str(arg)
        else:
            arg = repr(arg)

        arg = to_luaobj(arg)
        write(arg)
        write(sep)

    write("\n")

global isinstance
def isinstance(cls, targets):
    require_pyobj(obj)

    if type(cls) != type:
        cls = type(obj)

    mro = cls.mro()
    assert type(mro) == tuple

    for _, supercls in pairs(mro.value):
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

    for _, supercls in pairs(mro.value):
        require_pyobj(supercls)
        if supercls == targets:
            return True

    return False

global id
def id(obj):
    if is_pyobj(obj):
        return int(ObjectID_FromRef[obj])

    Fail_OP_Raw(obj, "__id__!")

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

        f = am[cx]
        if f:
            ret = f(a, b)
            if ret != NotImplemented: return ret

        # OP_Math2
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
    return ObjectID_FromRef[a] == ObjectID_FromRef[b]

def _OP__IsNot__(a, b):
    return not _OP__Is__(a, b)

__PC_ECMAXP_SETUP_AUTO_GLOBAL(true)
## Basic Call (Part A)
_OP__New__ = OP_Call(_M('__new__'))
_OP__Init__ = OP_Call(_M('__init__'))
_OP__Del__ = OP_Call(_M('__del__'))
_OP__Repr__ = OP_Call(_M('__repr__'))
_OP__Str__ = OP_Call(_M('__str__'))
_OP__Bytes__ = OP_Call(_M('__bytes__'))
_OP__Format__ = OP_Call(_M('__format__'))
_OP__Lt__ = OP_Call(_M('__lt__'))
_OP__Le__ = OP_Call(_M('__le__'))
_OP__Eq__ = OP_Call(_M('__eq__'))
_OP__Ne__ = OP_Call(_M('__ne__'))
_OP__Gt__ = OP_Call(_M('__gt__'))
_OP__Ge__ = OP_Call(_M('__ge__'))
_OP__Hash__ = OP_Call(_M('__hash__'))
_OP__Bool__ = OP_Call(_M('__bool__'))
_OP__Getattr__ = OP_Call(_M('__getattr__'))
_OP__Getattribute__ = OP_Call(_M('__getattribute__'))
_OP__Setattr__ = OP_Call(_M('__setattr__'))
_OP__Delattr__ = OP_Call(_M('__delattr__'))
_OP__Dir__ = OP_Call(_M('__dir__'))
_OP__Get__ = OP_Call(_M('__get__'))
_OP__Set__ = OP_Call(_M('__set__'))
_OP__Delete__ = OP_Call(_M('__delete__'))
_OP__Slots__ = OP_Call(_M('__slots__'))
_OP__Call__ = OP_Call(_M('__call__'))
_OP__Len__ = OP_Call(_M('__len__'))
_OP__Getitem__ = OP_Call(_M('__getitem__'))
_OP__Setitem__ = OP_Call(_M('__setitem__'))
_OP__Delitem__ = OP_Call(_M('__delitem__'))
_OP__Iter__ = OP_Call(_M('__iter__'))
_OP__Reversed__ = OP_Call(_M('__reversed__'))
_OP__Contains__ = OP_Call(_M('__contains__'))

## Math Operation (A * B)
_OP__Add__ = OP_Math2(_M('__add__'), _M('__radd__'))
_OP__Sub__ = OP_Math2(_M('__sub__'), _M('__rsub__'))
_OP__Mul__ = OP_Math2(_M('__mul__'), _M('__rmul__'))
_OP__Truediv__ = OP_Math2(_M('__truediv__'), _M('__rtruediv__'))
_OP__Floordiv__ = OP_Math2(_M('__floordiv__'), _M('__rfloordiv__'))
_OP__Mod__ = OP_Math2(_M('__mod__'), _M('__rmod__'))
_OP__Divmod__ = OP_Math2(_M('__divmod__'), _M('__rdivmod__'))
_OP__Pow__ = OP_Math2_Pow(_M('__pow__'), _M('__rpow__'))
_OP__Lshift__ = OP_Math2(_M('__lshift__'), _M('__rlshift__'))
_OP__Rshift__ = OP_Math2(_M('__rshift__'), _M('__rrshift__'))
_OP__And__ = OP_Math2(_M('__and__'), _M('__rand__'))
_OP__Xor__ = OP_Math2(_M('__xor__'), _M('__rxor__'))
_OP__Or__ = OP_Math2(_M('__or__'), _M('__ror__'))

## Math Operation (A *= B)
_OP__Iadd__ = OP_Math3(_M('__iadd__'), _M('__add__'), _M('__radd__'))
_OP__Isub__ = OP_Math3(_M('__isub__'), _M('__sub__'), _M('__rsub__'))
_OP__Imul__ = OP_Math3(_M('__imul__'), _M('__mul__'), _M('__rmul__'))
_OP__Itruediv__ = OP_Math3(_M('__itruediv__'), _M('__truediv__'), _M('__rtruediv__'))
_OP__Ifloordiv__ = OP_Math3(_M('__ifloordiv__'), _M('__floordiv__'), _M('__rfloordiv__'))
_OP__Imod__ = OP_Math3(_M('__imod__'), _M('__mod__'), _M('__rmod__'))
_OP__Ipow__ = OP_Math3_Pow(_M('__ipow__'), _M('__pow__'), _M('__rpow__'))
_OP__Ilshift__ = OP_Math3(_M('__ilshift__'), _M('__lshift__'), _M('__rlshift__'))
_OP__Irshift__ = OP_Math3(_M('__irshift__'), _M('__rshift__'), _M('__rrshift__'))
_OP__Iand__ = OP_Math3(_M('__iand__'), _M('__and__'), _M('__rand__'))
_OP__Ixor__ = OP_Math3(_M('__ixor__'), _M('__xor__'), _M('__rxor__'))
_OP__Ior__ = OP_Math3(_M('__ior__'), _M('__or__'), _M('__ror__'))

## Basic Call (Part B)
_OP__Neg__ = OP_Call(_M('__neg__'))
_OP__Pos__ = OP_Call(_M('__pos__'))
_OP__Abs__ = OP_Call(_M('__abs__'))
_OP__Invert__ = OP_Call(_M('__invert__'))
_OP__Complex__ = OP_Call(_M('__complex__'))
_OP__Int__ = OP_Call(_M('__int__'))
_OP__Float__ = OP_Call(_M('__float__'))
_OP__Round__ = OP_Call(_M('__round__'))
_OP__Index__ = OP_Call(_M('__index__'))
_OP__Enter__ = OP_Call(_M('__enter__'))
_OP__Exit__ = OP_Call(_M('__exit__'))

## Extra Call
_OP__Lua__ = OP_Call(_M('__lua__'))
__PC_ECMAXP_SETUP_AUTO_GLOBAL(false)

global object
@register_pyobj
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
        return lua.concat("#(", to_luaobj(repr(self)), ")")

    def __new__(cls, *args):
        instance = register_pyobj({})
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
        # TODO: Add PCEX Support!
        rawset(self, key, value)

    def __str__(self):
        return _OP__Repr__(self)

    def __repr__(self):
        mtable = getmetatable(self)
        return str(concat("<object ", mtable.__name__, " at ", tostring(self.__id),">"))

rawset(object, TAG, TAG)

global type
@register_pyobj
class type(object):
    def __call__(cls, *args):
        instance = cls.__new__(cls, *args)
        register_pyobj(instance)

        return instance

    def __repr__(cls):
        return str(lua.concat("<class '", cls.__name__, "'>"))

    def mro(cls):
        return cls.__mro__

@register_pyobj
class builtins_type(type):
    __name__ = "type"

    def __setattr__(self, name):
        error("Not allowed setattr for builtins type.")

@register_pyobj
class ptype(builtins_type):
    def __call__(cls, *args):
        if lua.len(args) == 1:
            require_pyobj(args[1])
            return getmetatable(args[1])
        elif lua.len(args) == 3:
            pass
        else:
            error("Unexcepted arguments.")

setmetatable(object, builtins_type)
setmetatable(type, ptype)
setmetatable(ptype, ptype)

@register_pyobj
class LuaObject(object, metatable=type):
    # This is hidden, and core of calc.
    LuaObject = true
    # isinstance are need.

    def __init__(self, obj):
        mtable = getmetatable(obj)
        if mtable and rawget(mtable, "LuaObject"):
            obj = to_luaobj(obj)

        object.__setattr__(self, "value", obj)

    def __str__(self):
        return str(_OP__Repr__(self))

    def __repr__(self):
        return str(tostring(self.value))

    def __lua__(self):
        return self.value

@register_pyobj
class LuaValueOnlySequance(LuaObject, metatable=type):
    def __init__(self, obj):
        self.check_type(obj)
        object.__setattr__(self, "value", obj)

    def check_type(self, obj):
        if obj[lua.len(obj)] is nil: pass
        elif obj[1] is nil: pass
        elif obj[0] is not nil: pass
        else:
            return true

        return false

global list
@register_pyobj
class list(LuaValueOnlySequance, metatable=type):
    def __repr__(self):
        ret = []
        idx = 1

        sep = ""
        ret[idx] = "["; idx += 1
        for k,v in pairs(self.value):
            ret[idx] = sep; idx += 1
            ret[idx] = to_luaobj(repr(v)); idx += 1
            sep = ", "

        ret[idx] = "]"; idx += 1

        return table.concat(ret)

    def __setattr__(self, key, value):
        error("Not allowed")

global tuple
@register_pyobj
class tuple(LuaValueOnlySequance, metatable=type):
    def __repr__(self):
        ret = []
        idx = 1

        sep = ""
        ret[idx] = "("; idx += 1
        for k,v in pairs(self.value):
            ret[idx] = sep; idx += 1
            ret[idx] = to_luaobj(repr(v)); idx += 1
            sep = ", "

        ret[idx] = ")"; idx += 1

        return table.concat(ret)

    def __setattr__(self, key, value):
        error("Not allowed")

global str
@register_pyobj
class str(LuaObject, metatable=type):
    def __init__(self, value):
        if is_pyobj(value):
            value = _OP__Str__(value)
            value = to_luaobj(value)

        self.value = value

    def __str__(self):
        return self

    def __repr__(self):
        return str(lua.concat("'", self.value, "'"))

global bool
@register_pyobj
class bool(LuaObject, metatable=type):
    def __new__(self, value):
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
        if self.value == true:
            return str("True")
        elif self.value == false:
            return str("False")

def make_bool(value):
    instance = {"value": value}
    register_pyobj(instance)
    setmetatable(instance, bool)

    return instance

LUA_CODE("True = make_bool(true)")
LUA_CODE("False = make_bool(false)")

global int
@register_pyobj
class int(LuaObject, metatable=type):
    def __add__(self, other):
        # TODO: We must use pattern for something.
        return int(self.value + other.value)

global dict
@register_pyobj
class dict(LuaObject, metatable=type):
    pass

build_builtins_cls_bases(object)
build_builtins_cls_bases(type, object)
build_builtins_cls_bases(list, object)
build_builtins_cls_bases(str, object)
build_builtins_cls_bases(int, object)
build_builtins_cls_bases(dict, object)


###

x = list({int(1), int(2), int(3)})
y = int(5)
z = int(7)

print(x)
print(True is nil)
print(True)
print(issubclass(int, object))
print(int.mro())
print(_OP__Add__(y, z))