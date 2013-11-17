if pyscripter: exit(__import__('pc').main())
### THE HACK FOR RUN py-API.py in pyscripts.

global lua

lua = {}
for key, value in pairs(_G):
    lua[key] = value

TAG = '[PY]'
OBJ_ID = 0

def lua_len(obj):
    return LUA_CODE("#obj")

def lua_concat(*args):
    r = ""
    for _, str in pairs(args):
        r = LUA_CODE("r..str")

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
    value = rawget(mtable, fname)
    return value(obj, *args)

def repr(obj):
    return metacall(to_pyobj(obj), "__repr__")

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
        return concat("@", to_luaobj(repr(self)))

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

        error("?")

    def __setattr__(self, key, value):
        rawset(self, key, value)

    def __repr__(self):
        mtable = getmetatable(self)
        return str(concat("<object ", mtable.__name__, " at ", tostring(self.__id),">"))

rawset(object, TAG, TAG)

class type(object):
    def __call__(cls, *args):
        return cls.__new__(cls, *args)

    def __repr__(cls):
        return str(lua.concat("<class '", cls.__name__, "'>"))

    def mro(cls):
        return cls.__mro__

class ptype(type):
    def __call__(cls, *args):
        if lua.len(args) == 1:
            #require_pyobj(args[1])
            return getmetatable(args[1])
        elif lua.len(args) == 3:
            pass
        else:
            error("Unexcepted arguments.")

setmetatable(object, type)
setmetatable(type, ptype)
setmetatable(ptype, ptype)

class LuaObject(object, metatable=type):
    def __init__(self, obj):
        self.value = obj

    def __repr__(self):
        return tostring(self.value)

    def __lua__(self):
        return self.value

class str(LuaObject, metatable=type):
    def __str__(self):
        return self

    def __repr__(self):
        return lua.concat("'", self.value, "'")

class int(LuaObject, metatable=type):
    pass

def is_float(num):
    if lua.type(num) != "number":
        error("This is not number", 2)

    return math.floor(num) != num

def is_pyobj(obj):
    mtable = lua.getmetatable(obj)
    return mtable and rawget(mtable, TAG) == TAG

def to_pyobj(obj):
    if is_pyobj(obj):
        return obj
    else:
        objtype = lua.type(obj)
        if objtype == "number":
            if not is_float(obj):
                return int(obj)
            else:
                return float(obj)
        elif objtype == "string":
            return str(obj)
        else:
            return LuaObject(obj)

def to_luaobj(obj):
    if is_pyobj(obj):
        return obj.__lua__()
    else:
        return obj

def require_pyobj(*objs):
    for idx, obj in pairs(objs):
        if not is_pyobj(obj):
            error("Require python object.")

    return false

##def isinstance(obj, targets):
##  require_pyobj(obj)
##
##  cls = type(obj)
##  for _, supercls in pairs(cls.mro()):
##    if supercls == targets:
##      return true
##
##  return false

def repr(obj):
    obj = to_pyobj(obj)
    return metacall(obj, "__repr__")

def print(*args):
    write = lua.io.write
    sep = " "

    for _, arg in pairs(args):
        write(tostring(to_luaobj(str(arg))))
        write(sep)

    write("\n")

def _OP__Add__(a, b):
    assert require_pyobj(a, b)

    ret = metacall(a, "__add__", b)
    if ret != NotImplemented:
        return ret

    ret = b.__radd__(a)
    if ret != NotImplemented:
        return ret

    ret = b.__add__(a)
    if ret != NotImplemented:
        return ret

    fail_op()

print("hello")