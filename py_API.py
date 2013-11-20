if pyscripter: exit(__import__('pc').main())
### THE HACK FOR RUN py-API.py in pyscripts.
__PC_ECMAXP_ARE_THE_GOD_IN_THIS_WORLD("YES")
__PC_ECMAXP_SETUP_PCEX(true) # __PCEX__ YES!

global lua

lua = {}
for key, value in pairs(_G):
    lua[key] = value

TAG = '[PY]'
OBJ_ID = 0

__PCEX__ = "__PCEX__"
methods = GET_METHODS()

def lua_len(obj):
    return LUA_CODE("#obj")

def lua_concat(*args):
    r = ""
    for _, x in pairs(args):
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

def metacall(obj, fname, *args):
    mtable = getmetatable(obj)
    func = rawget(mtable, fname)
    if func is nil:
        error(lua.concat("Method ", fname, " are not found!"), 1)
    else:
        return func(obj, *args)

def safemetacall(obj, fname, *args):
    mtable = getmetatable(obj)
    func = rawget(mtable, fname)
    if func is nil:
        return false, nil
    else:
        return true, func(obj, *args)

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
        return metacall(obj, "__lua__")
    else:
        return obj

def require_pyobj(*objs):
    for idx, obj in pairs(objs):
        if not is_pyobj(obj):
            error("Require python object.")

    return true

global repr
def repr(obj):
    if is_pyobj(obj):
        return _OP__Repr__(obj)
    else:
        return lua.concat("@(", tostring(obj), ")")

global object
class object():
    def __init__(self):
        pass

    def __call(self, *args):
        return metacall(self, "__call__", *args)

    def __index(self, key):
        return metacall(self, "__getattribute__", key)

    def __newindex(self, key, value):
        return metacall(self, "__setattr__", key, value)

    def __tostring(self):
        return lua.concat("#(", to_luaobj(repr(self)), ")")

    def __new__(cls, *args):
        global OBJ_ID
        OBJ_ID += 1

        instance = {"__id" : OBJ_ID}
        lua.setmetatable(instance, cls)
        metacall(instance, "__init__", *args)

        return instance

    def __getattribute__(self, key):
        value = rawget(self, key)
        if value is not nil:
            return value

        mtable = getmetatable(self)
        value = rawget(mtable, key)
        if value is not nil:
            if lua.type(value) == "function":
                return lambda *args: value(self, *args)
            else:
                return value

        error(lua.concat("Not found '", key, "' attribute."))

    def __setattr__(self, key, value):
        rawset(self, key, value)

    def __repr__(self):
        mtable = getmetatable(self)
        return str(concat("<object ", mtable.__name__, " at ", tostring(self.__id),">"))

rawset(object, TAG, TAG)

global type
class type(object):
    def __call__(cls, *args):
        return cls.__new__(cls, *args)

    def __repr__(cls):
        return str(lua.concat("<class '", cls.__name__, "'>"))

    def mro(cls):
        return cls.__mro__

class builtins_type(type):
    __name__ = "type"

    def __setattr__(self, name):
        error("Not allowed setattr for builtins type.")

class ptype(builtins_type):
    def __call__(cls, *args):
        if lua.len(args) == 1:
            #require_pyobj(args[1])
            return getmetatable(args[1])
        elif lua.len(args) == 3:
            pass
        else:
            error("Unexcepted arguments.")

setmetatable(object, builtins_type)
setmetatable(type, ptype)
setmetatable(ptype, ptype)

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
        return str(metacall(self, "__repr__"))

    def __repr__(self):
        return str(tostring(self.value))

    def __lua__(self):
        return self.value

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

global str
class str(LuaObject, metatable=type):
    def __init__(self, value):
        if is_pyobj(value):
            value = metacall(value, "__str__")
            value = to_luaobj(value)

        self.value = value

    def __str__(self):
        return self

    def __repr__(self):
        return str(lua.concat("'", self.value, "'"))

global int
class int(LuaObject, metatable=type):
    def __add__(self, other):
        # TODO: We must use pattern for something.
        return int(self.value + other.value)

global dict
class dict(LuaObject, metatable=type):
    pass

##def isinstance(obj, targets):
##  require_pyobj(obj)
##
##  cls = type(obj)
##  for _, supercls in pairs(cls.mro()):
##    if supercls == targets:
##      return true
##
##  return false

global print
def print(*args):
    write = lua.io.write
    sep = " "

    for _, arg in pairs(args):
        write(tostring(to_luaobj(str(arg))))
        write(sep)

    write("\n")

def OP_Call(x):
    def func(o):
        assert require_pyobj(o)
        return rawget(getmetatable(o), __PCEX__)[x](o)
    return func

def OP_Call2(ax, bx):
    def func(a, b):
        assert require_pyobj(a, b)

        am = rawget(getmetatable(a), __PCEX__)
        bm = rawget(getmetatable(b), __PCEX__)

        f = am[ax]
        if f:
            ret = f(a, b)
            if ret != NotImplemented:
                return ret

        f = bm[bx]
        if f:
            ret = f(b, a)
            if ret != NotImplemented:
                return ret

        f = bm[ax]
        if f:
            ret = f(b, a)
            if ret != NotImplemented:
                return ret

        error(lua.concat("Can't do '", ax, "'"))

    return func

global _OP__Add__, _OP__Sub__, _OP__Repr__
_OP__Add__ = OP_Call2(_M("__add__"), _M("__radd__"))
_OP__Sub__ = OP_Call2(_M("__sub__"), _M("__rsub__"))
_OP__Repr__ = OP_Call(_M("__repr__"))

x = list({int(1), int(2), int(3)})
y = int(5)
z = int(7)
print(x)
print(_OP__Add__(y, z))
lua.print(list.__PCEX__[_M("__repr__")])