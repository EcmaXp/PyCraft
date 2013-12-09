if pyscripter: exit(__import__('pc').main())
### THE HACK FOR RUN py-API.py in pyscripts.
__PC_ECMAXP_ARE_THE_GOD_IN_THIS_WORLD("YES")
__PC_ECMAXP_SETUP_ACCESS_FOR_VALUE(false)
global _M # Already _M is local thing. :$

if not getmetatable(_M) or _G == _M:
    # This Logic are support
    #  - run at pure lua
    #  - run at cc's shell (with no change environ)
    #  - run by loadAPI (with export environ)

    _M = setmetatable({"_G":_G}, {"__index":_G})
    setfenv(1, _M)

#global lua
lua = {}
lua.len = lambda obj: LUA_CODE("#obj")
lua.concat = lambda *args: table.concat(args)
lua.write = write or io.write
lua.yield_ = coroutine['yield']
lua.format = string.format
for key, value in pairs(_G):
    lua[key] = value

PY_OBJ_TAG = "#"
LUA_OBJ_TAG = "@"

BIT_WIDTH = 8 # 32 Bit System
TAG = "[PY]"
ObjLastID = 0
inited = False

builtins = "builtins"

## This table are weaktable.
ObjData = setmetatable({}, {"__mode":"k"}) # i=id, v=value, h=hash
ObjPCEX = setmetatable({}, {"__mode":"k"}) # small table for fast find
Obj_FromID = setmetatable({}, {"__mode":"v"})

BuiltinTypes = setmetatable({}, {"__mode":"k"})
## must cleaned after collectgarbage()

## pairs with weakref table are unsafe!
InitalBuiltinTypes = {}
##

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
    return ObjData[obj] is not nil

global PObj
def PObj(obj):
    if is_pyobj(obj):
        return obj
    else:
        return LuaObject(obj)

global LObj
def LObj(obj):
    if is_pyobj(obj):
        return _OP__Lua__(obj)
    else:
        return obj

def require_pyobj(*objs):
    for idx, obj in pairs(objs):
        if not is_pyobj(obj):
            error("Require python object.")

    return true

raw_id = nil
def register_pyobj(obj, obj_id):
    if obj_id is nil:
        obj_id = raw_id(obj)

    assert ObjData[obj] is nil

    ObjData[obj] = {}
    ObjData[obj].i = obj_id
    Obj_FromID[obj_id] = obj

def error(msg, level):
    if level is nil:
        level = 1

    msg = LObj(msg)

    level += 1
    msg = lua.format("%s %s", TAG, tostring(msg))

    lua.error(msg, level) #--[DEBUG; ERROR POINT]--#

def require_args(*args):
    for key, value in pairs(args):
        if value is nil:
            error("SystemError: Not Enough Item")

    return True

def nonrequire_args(*args):
    for key, value in pairs(args):
        if value is not nil:
            error("SystemError: Too Many Item")

    return True

def is_float(num):
    if lua.type(num) != "number":
        error("This is not number", 2)

    return math.floor(num) != num

_C3_MRO = nil # define local
class _C3_MRO(): # This is container. not like class.
    # https://gist.github.com/eric-wieser/3804277
    def merge(seqs):
        res = {}
        while true:
            # filter out empty sequences
            nonemptyseqs = {}
            for _, seq in ipairs(seqs):
                if lua.len(seq) > 0: table.insert(nonemptyseqs, seq)

            # all sequences empty? we're done!
            if lua.len(nonemptyseqs) == 0:
                return res

            #find merge candidates among seq heads
            cand = nil
            set_break = false
            for _, seq in ipairs(nonemptyseqs):
                if not set_break:
                    cand = seq[1]
                    # check if the candidate is in the tail of any sequence
                    def intail():
                        for _, nonemptyseq in ipairs(nonemptyseqs):
                            for j, cls in ipairs(nonemptyseq):
                                if j > 1 and cls == cand:
                                    return true

                        return false
                    intail = intail()

                    if not intail:
                        set_break = true
                    else:
                        cand = nil # reject candidate

            # add new entry
            if not cand:
                error("Inconsistent hierarchy", 2)
            else:
                table.insert(res, cand)
                for _, seq in ipairs(nonemptyseqs): # remove cand
                    if seq[1] == cand:
                        table.remove(seq, 1)

    def mro(C):
        # Compute the class precedence list (mro) according to C3
        mros = {}
        basesCopy = {} # we need to copy C.__bases__ so that it isn't modified
        table.insert(mros, {C})
        for _, base in ipairs(C.__bases__):
            mro = _C3_MRO.get_cached_mro(base)
            if mro is nil:
                mro = _C3_MRO.mro(base)

            table.insert(mros, mro)
            table.insert(basesCopy, base)

        table.insert(mros, basesCopy)
        return _C3_MRO.merge(mros)

    def get_cached_mro(C):
        if not inited:
            if C.__mro__ is nil:
                return nil

            new_mro = {} # for work with mro() func
            for k, v in pairs(C.__mro__):
                new_mro[k] = v

            return new_mro

        error("FAILED")

def hide_class_from_seq(seq):
    new_seq = {}
    idx = 1

    for k, v in pairs(seq):
        if InitalBuiltinTypes[v] is not nil:
            new_seq[idx] = v
            idx += 1

    return new_seq

def setup_base_class(cls):
    pcex = {}
    for k, v in pairs(cls):
        idx = builtin_methods_rev[k]
        if idx is not nil:
            pcex[idx] = v

    pcls = getmetatable(cls)

    register_pyobj(cls)
    ObjPCEX[cls] = pcex
    InitalBuiltinTypes[cls] = false

    cls.__mro__ = _C3_MRO.mro(cls)

    return cls

def setup_basic_class(cls):
    setup_base_class(cls)
    setmetatable(cls, type)

    return cls

def setup_hide_class(cls):
    InitalBuiltinTypes[cls] = nil
    return cls

def register_builtins_class(cls):
    if cls != object:
        cls.__base__ = object
    else:
        cls.__base__ = None

    cls.__name__ = str(rawget(cls, "__name__"))
    cls.__module__ = str("builtins")
    cls.__bases__ = tuple(hide_class_from_seq((cls.__bases__)))
    cls.__mro__ = tuple(hide_class_from_seq((cls.__mro__)))

    InitalBuiltinTypes[cls] = true
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
        f = ObjPCEX[getmetatable(a)][ax]
        if f:
            return f(a, *args)

        Fail_OP(a, ax)
    return func

def OP_Math1(vx, wx): # binary_op1
    def func(v, w):
        assert require_pyobj(v, w)
        vm = ObjPCEX[getmetatable(v)]
        wm = ObjPCEX[getmetatable(w)]

        vf = vm[vx]
        if vm != wm:
            wf = wm[wx]
            if vf == wf:
                wf = nil

        if vf:
            if wf and issubclass(type(w), type(v)):
                x = wf(w, v)
                if x != NotImplemented: return x
                wf = nil

            x = vf(v, w)
            if x != NotImplemented: return x

        if wf:
            x = wf(w, v)
            if x != NotImplemented: return x

        Fail_OP_Math(v, w, vx)

    return func

def OP_Math2(vx, wx, zx): # binary_iop1
    op = OP_Math1(wx, zx)
    def func(v, w):
        assert require_pyobj(v, w)
        vm = ObjPCEX[getmetatable(v)]

        vf = vm[vx]
        if vf:
            x = vf(v, w)
            if x != NotImplemented: return x

        return op(v, w)

    return func

def OP_Math1_Pow(vx, wx): # ternary_op?
    def func(v, w, z):
        assert require_pyobj(v, w)
        vm = ObjPCEX[getmetatable(v)]
        wm = ObjPCEX[getmetatable(w)]

        vf = vm[vx]
        if vm != wm:
            wf = wm[wx]
            if vf == wf:
                wf = nil

        if vf:
            if wf and issubclass(type(w), type(v)):
                x = wf(w, v, z)
                if x != NotImplemented: return x
                wf = nil

            x = vf(v, w, z)
            if x != NotImplemented: return x

        if wf:
            x = wf(w, v, z)
            if x != NotImplemented: return x

        Fail_OP_Math_Pow(v, w, vx, z)

    return func

def OP_Math2_Pow(vx, wx, zx): # ternary_op (with i)
    op = OP_Math1_Pow(wx, zx)
    def func(v, w, z):
        assert require_pyobj(v, w) and (z is nil or require_pyobj(z))
        vm = ObjPCEX[getmetatable(v)]

        vf = vm[vx]
        if vf:
            x = vf(v, w, z)
            if x != NotImplemented: return x

        return op(v, w, z)

    return func

global _OP__Is__, _OP__IsNot__
def  _OP__Is__(a, b):
    require_pyobj(a, b)
    return ObjData[a].i == ObjData[b].i

def _OP__IsNot__(a, b):
    return not _OP__Is__(a, b)

global _OP__ForIter__
def _OP__ForIter__(ret):
    return LObj(iter(ret))

global _OP__SetupGenFunc__
def _OP__SetupGenFunc__(func):
    def func2():
        # TODO: add try~except and handle error!
        def body(*args):
            func(*args)

        return generator(coroutine.create(body))

    return func2

_OP__Yield__ = lua.yield_

def _OP__Call__(func, args, kwargs):
    pass

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
_OP__Bool__ = OP_Call(_('__bool__')) # TypeError: __bool__ should return bool, returned xxx
_OP__Getattr__ = OP_Call(_('__getattr__'))
_OP__Getattribute__ = OP_Call(_('__getattribute__'))
_OP__Setattr__ = OP_Call(_('__setattr__'))
_OP__Delattr__ = OP_Call(_('__delattr__'))
_OP__Dir__ = OP_Call(_('__dir__'))
_OP__Get__ = OP_Call(_('__get__'))
_OP__Set__ = OP_Call(_('__set__'))
_OP__Delete__ = OP_Call(_('__delete__'))
_OP__Slots__ = OP_Call(_('__slots__'))
_OP__RawCall__ = OP_Call(_('__call__'))
_OP__Len__ = OP_Call(_('__len__'))
_OP__Getitem__ = OP_Call(_('__getitem__'))
_OP__Setitem__ = OP_Call(_('__setitem__'))
_OP__Delitem__ = OP_Call(_('__delitem__'))
_OP__Iter__ = OP_Call(_('__iter__'))
_OP__Reversed__ = OP_Call(_('__reversed__'))
_OP__Contains__ = OP_Call(_('__contains__'))

## Math Operation (A * B)
_OP__Add__ = OP_Math1(_('__add__'), _('__radd__'))
_OP__Sub__ = OP_Math1(_('__sub__'), _('__rsub__'))
_OP__Mul__ = OP_Math1(_('__mul__'), _('__rmul__'))
_OP__Truediv__ = OP_Math1(_('__truediv__'), _('__rtruediv__'))
_OP__Floordiv__ = OP_Math1(_('__floordiv__'), _('__rfloordiv__'))
_OP__Mod__ = OP_Math1(_('__mod__'), _('__rmod__'))
_OP__Divmod__ = OP_Math1(_('__divmod__'), _('__rdivmod__'))
_OP__Pow__ = OP_Math1_Pow(_('__pow__'), _('__rpow__'))
_OP__Lshift__ = OP_Math1(_('__lshift__'), _('__rlshift__'))
_OP__Rshift__ = OP_Math1(_('__rshift__'), _('__rrshift__'))
_OP__And__ = OP_Math1(_('__and__'), _('__rand__'))
_OP__Xor__ = OP_Math1(_('__xor__'), _('__rxor__'))
_OP__Or__ = OP_Math1(_('__or__'), _('__ror__'))

## Math Operation (A *= B)
_OP__Iadd__ = OP_Math2(_('__iadd__'), _('__add__'), _('__radd__'))
_OP__Isub__ = OP_Math2(_('__isub__'), _('__sub__'), _('__rsub__'))
_OP__Imul__ = OP_Math2(_('__imul__'), _('__mul__'), _('__rmul__'))
_OP__Itruediv__ = OP_Math2(_('__itruediv__'), _('__truediv__'), _('__rtruediv__'))
_OP__Ifloordiv__ = OP_Math2(_('__ifloordiv__'), _('__floordiv__'), _('__rfloordiv__'))
_OP__Imod__ = OP_Math2(_('__imod__'), _('__mod__'), _('__rmod__'))
_OP__Ipow__ = OP_Math2_Pow(_('__ipow__'), _('__pow__'), _('__rpow__'))
_OP__Ilshift__ = OP_Math2(_('__ilshift__'), _('__lshift__'), _('__rlshift__'))
_OP__Irshift__ = OP_Math2(_('__irshift__'), _('__rshift__'), _('__rrshift__'))
_OP__Iand__ = OP_Math2(_('__iand__'), _('__and__'), _('__rand__'))
_OP__Ixor__ = OP_Math2(_('__ixor__'), _('__xor__'), _('__rxor__'))
_OP__Ior__ = OP_Math2(_('__ior__'), _('__or__'), _('__ror__'))

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
        return lua.format("%s(%s)", LUA_OBJ_TAG, tostring(obj))

def print(*args):
    arr = []
    idx = 1

    for _, arg in pairs(args):
        if is_pyobj(arg):
            arg = str(arg)
        else:
            arg = repr(arg)

        arg = LObj(arg)

        arr[idx] = arg
        idx += 1

    data = table.concat(arr, " ")
    data = lua.concat(data, "\n")
    lua.write(data)

def isinstance(obj, targets):
    require_pyobj(obj)

    cls = type(obj)
    #TODO: how to?
    #mro = cls.mro()
    #assert type(mro) == list
    mro = cls.__mro__
    assert type(mro) == tuple

    if type(targets) == tuple:
        targets = LObj(targets)
    else:
        targets = {targets}

    for _, supercls in pairs(_OP__Lua__(mro)):
        require_pyobj(supercls)
        for k, target in pairs(targets):
            if supercls == target:
                return True

    return False

def issubclass(cls, targets):
    require_pyobj(obj)

    if type(cls) != type:
        error("issubclass() arg 1 must be a class")

    mro = cls.__mro__
    assert type(mro) == tuple

    if type(targets) == tuple:
        targets = LObj(targets)
    else:
        targets = {targets}

    for _, supercls in pairs(_OP__Lua__(mro)):
        require_pyobj(supercls)
        for k, target in pairs(targets):
            if supercls == target:
                return True
    return False

def id(obj):
    if is_pyobj(obj):
        return int(ObjData[obj].i)

    Fail_OP_Raw(obj, "__id!")

def iter(ret):
    ret = _OP__Iter__(ret)
    if isinstance(ret, generator) == False:
        error(TypeError("iter are only accept generator!"))

    return ret

def len(obj):
    return _OP__Len__(obj)

__PC_ECMAXP_SETUP_AUTO_GLOBAL(false)
_ = nil
## end?

def _raw_id(obj):
    return tonumber(string.sub(tostring(obj), 8), 16)

def raw_id(obj):
    if lua.type(obj) != "table":
        Fail_OP_Raw(obj, "__raw_id!")

    cls = getmetatable(obj)
    if cls is nil:
        obj_id = _raw_id(obj)
    else:
        setmetatable(obj, nil)
        obj_id = _raw_id(obj)
        setmetatable(obj, cls)

    return obj_id

global object
@setup_base_class
class object():
    def __init__(self):
        pass

    def __call(self, *args):
        return _OP__RawCall__(self, *args)

    def __index(self, key):
        return _OP__Getattribute__(self, key)

    def __newindex(self, key, value):
        return _OP__Setattr__(self, key, value)

    def __tostring(self):
        return lua.format("%s(%s)", PY_OBJ_TAG, LObj(repr(self)))

    def __new__(cls, *args):
        instance = {}
        register_pyobj(instance, _raw_id(instance))
        lua.setmetatable(instance, cls)
        _OP__Init__(instance, *args)

        return instance

    def __getattribute__(self, k):
        # TODO: support non str object (with PyObj)
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

        for k, v in pairs(self):
            if _OP__Eq__(k, v):
                return v

        error(lua.format("Not found '%s' attribute.", k))

    def __setattr__(self, key, value):
        cls = type(self)
        if BuiltinTypes[cls] and inited:
            basemsg = "can't set attributes of built-in/extension type "
            error(TypeError(lua.concat(basemsg, LObj(repr(cls.__name__)))))

        rawset(self, key, value)

    def __delattr__(self, key, value):
        # That is safe?
        object.__setattr__(self, key, nil)

    def __eq__(self, other):
        return self == other

    def __ne__(self, other):
        return self != other

    def __hash__(self, other):
        return id(self)

    def __str__(self):
        return _OP__Repr__(self)

    def __repr__(self):
        mtable = getmetatable(self)
        name = mtable.__name__
        oid = id(self)
        oid = lua.format("000000000%X", LObj(oid))
        oid = lua.string.sub(oid, -BIT_WIDTH)

        return str(lua.format("<object %s at 0x%s>", LObj(name), oid))

    def __bool__(self):
        return True

global type
@setup_base_class
class type(object):
    def __call__(cls, *args):
        return cls.__new__(cls, *args)

    def __repr__(cls):
        return str(lua.concat("<class '", LObj(cls.__name__), "'>"))

    def mro(cls):
        return list(ObjData[cls.__mro__].v) # TODO: list(cls.__mro__) direct!

@setup_base_class
@setup_hide_class
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

## for exception
__PC_ECMAXP_SETUP_AUTO_GLOBAL(true)

@setup_basic_class
class BaseException(object):
    # TODO: Support with sys.last_value

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
class TypeError(Exception, BaseException):
    pass

@setup_basic_class
class UnstableException(Exception, BaseException):
    pass

__PC_ECMAXP_SETUP_AUTO_GLOBAL(false)

@setup_basic_class
@setup_hide_class
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

    def __lua__(self):
        return nil

@setup_basic_class
@setup_hide_class
class LuaObject(object):
    def __init__(self, obj):
        if is_pyobj(obj):
            error(Exception("Not allowed wrapping python object!"))

        assert obj != nil
        ObjData[self].v = obj

    def __str__(self):
        return str(_OP__Repr__(self))

    def __repr__(self):
        return str(tostring(ObjData[self].v))

    def __lua__(self):
        return ObjData[self].v

global generator
@setup_basic_class
class generator(LuaObject):
    def __init__(self, obj):
        if is_pyobj(obj):
            error(TypeError("cannot create 'generator' instances"), 1)
        elif lua.type(obj) != "thread":
            error(TypeError("gernerator only accept lua.type 'thread' object."), 1)

        LuaObject.__init__(self, obj)

    # TODO: Support next?

    def __next__(self):
        return LObj(genbody)()

    def __repr__(self):
        return str(tostring(ObjData[self].v))

    def __lua__(self):
        t = ObjData[self].v
        def genbody():
            success, value = coroutine.resume(t)
            if not success:
                return nil

            return value

        return genbody

    def __iter__(self):
        return self

def require_lua_sequance(value):
    if lua.type(value) != "table": pass
    elif lua.len(value) == 0:
        return true # special, empty table don't require any vaild.
    elif value[lua.len(value)] is nil: pass
    elif value[1] is nil: pass
    elif value[0] is not nil: pass
    else:
        return true

    error(Exception("Not allowed unknown table (or other thing)!"))

global list
@setup_basic_class
class list(LuaObject):
    def __init__(self, value):
        start = {}
        new = nil
        cur = start
        for k, v in pairs(value):
            new = {}
            cur.v = v

            new.p = cur
            cur.n = new
            cur = new

        if new.p:
            new.p.n = nil

        LuaObject.__init__(self, start)

    def __getitem__(self, x):
        x = _OP__Index__(x)
        x = LObj(x)

        cur = ObjData[self].v
        assert x >= 0
        while x != 0:
            cur = cur.n
            x -= 1

        return cur.v

    def __repr__(self):
        ret = {}
        idx = 1
        sep = ""

        ret[idx] = "["; idx += 1
        cur = ObjData[self].v
        while cur is not nil:
            ret[idx] = sep; idx += 1
            ret[idx] = LObj(repr(cur.v)); idx += 1
            sep = ", "

            cur = cur.n

        ret[idx] = "]"; idx += 1
        return table.concat(ret)

    def __lua__(self):
        #TODO: make use iter or other thing for don't copy.
        ret = {}
        idx = 1

        cur = ObjData[self].v
        while cur is not nil:
            ret[idx] = cur.v; idx += 1
            cur = cur.n

        return ret

global tuple
@setup_basic_class
class tuple(LuaObject):
    def __init__(self, obj):
        LuaObject.__init__(self, obj)
        assert require_lua_sequance(obj)

    def __repr__(self):
        return self.make_repr("(", ")")

    def __len__(self):
        return int(lua.len(ObjData[self].v))

    def __getitem__(self, x):
        x = _OP__Index__(x)
        x = LObj(x)
        assert x >= 0
        return ObjData[self].v[LObj(x) + 1]

    def __repr__(self):
        value = ObjData[self].v
        ret = {}
        idx = 1

        sep = ""
        ret[idx] = "("; idx += 1
        for k,v in pairs(value):
            ret[idx] = sep; idx += 1
            ret[idx] = LObj(repr(v)); idx += 1
            sep = ", "

        if lua.len(value) == 1:
            ret[idx] = ","; idx += 1

        ret[idx] = ")"; idx += 1

        return table.concat(ret)

    def __iter__(self):
        value = ObjData[self].v
        idx = 1

        @_OP__SetupGenFunc__
        def body():
            nonlocal idx
            while value[idx] is not nil:
                _OP__Yield__(value[idx])
                idx += 1

        return body()

#list = tuple # list are broken, wait until fix. (with linked list!)

global str
@setup_basic_class
class str(LuaObject):
    def __init__(self, value):
        if is_pyobj(value):
            value = _OP__Str__(value)
            value = LObj(value)

        ObjData[self].v = value

    def __str__(self):
        return self

    def __repr__(self):
        return str(lua.concat("'", ObjData[self].v, "'"))

    def __len__(self):
        return int(lua.len(ObjData[self].v))

@setup_basic_class
@setup_hide_class
class LuaNum(LuaObject):
    def __add__(self, other):
        return ObjData[self].v + ObjData[other].v

    def __sub__(self, other):
        return ObjData[self].v - ObjData[other].v

    def __mul__(self, other):
        return ObjData[self].v * ObjData[other].v

    def __truediv__(self, other):
        return float(ObjData[self].v / ObjData[other].v)

    def __radd__(self, other):
        return ObjData[other].v + ObjData[self].v

    def __rsub__(self, other):
        return ObjData[other].v - ObjData[self].v

    def __rmul__(self, other):
        return ObjData[other].v * ObjData[self].v

    def __rtruediv__(self, other):
        return float(ObjData[other].v / ObjData[self].v)

def int_chk_other(other):
    if isinstance(other, int) == False: return NotImplemented

global int
@setup_basic_class
class int(LuaNum):
    def __add__(self, other):
        return int_chk_other(other) or int(LuaNum.__add__(self, other))

    def __sub__(self, other):
        return int_chk_other(other) or int(LuaNum.__sub__(self, other))

    def __mul__(self, other):
        return int_chk_other(other) or int(LuaNum.__mul__(self, other))

    def __radd__(self, other):
        return int_chk_other(other) or int(LuaNum.__radd__(self, other))

    def __rsub__(self, other):
        return int_chk_other(other) or int(LuaNum.__rsub__(self, other))

    def __rmul__(self, other):
        return int_chk_other(other) or int(LuaNum.__rmul__(self, other))

    def __hash__(self):
        pass

    def __index__(self):
        return int(ObjData[self].v)

BOOL_TRUE = 1
BOOL_FALSE = 0

global bool
@setup_basic_class
class bool(int):
    def __init__(cls):
        pass

    def __new__(cls, value):
        if not inited:
            instance = object.__new__(cls)
            if value == true:
                value = BOOL_TRUE
            elif value == false:
                value = BOOL_FALSE
            ObjData[instance].v = value
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

    def __bool__(self):
        return self

    def __repr__(self):
        value = ObjData[self].v
        if value == BOOL_TRUE:
            return str("True")
        elif value == BOOL_FALSE:
            return str("False")

    def __lua__(self):
        value = ObjData[self].v
        if value == BOOL_TRUE:
            return true
        elif value == BOOL_FALSE:
            return false

# int_cache = {}

def float_chk_other(other):
    if isinstance(other, int) == True:
        return
    elif isinstance(other, float) == True:
        return
    else:
        return NotImplemented

global float
@setup_basic_class
class float(LuaNum):
    def __add__(self, other):
        return float_chk_other(other) or float(LuaNum.__add__(self, other))

    def __sub__(self, other):
        return float_chk_other(other) or float(LuaNum.__sub__(self, other))

    def __mul__(self, other):
        return float_chk_other(other) or float(LuaNum.__mul__(self, other))

    def __radd__(self, other):
        return float_chk_other(other) or float(LuaNum.__radd__(self, other))

    def __rsub__(self, other):
        return float_chk_other(other) or float(LuaNum.__rsub__(self, other))

    def __rmul__(self, other):
        return float_chk_other(other) or float(LuaNum.__rmul__(self, other))

global dict
@setup_basic_class
class dict(LuaObject):
    pass

##@setup_basic_class
##class function(LuaObject):
##    def __call__(self, *args):
##        pass

# parse_func_kwargs(args, kwargs, 3, None, 2, "kwargs", "a", "b", "c")
def parse_func_args(args, kwargs, al, a, *fargs_):
    return parse_func_kwargs(args, kwargs, al, a, 0, None)

def parse_func_kwargs(args, kwargs, al, a, kl, k, *fargs_):
    ret = []

    idx = 1
    fargs = fargs_

    assert isinstance(args, tuple)
    args = LObj(args)
    kwargs = LObj(kwargs)
    total_count = al + kl
    count = 0

    if args is not nil:
        tmp = []

        x = lua.length(args)
        y = al
        z = x - y
        while count > 0:
            tmp[idx] = args[idx]

            idx += 1
            count -= 1


    if kwargs is not nil:
        pass



def parse_func_args(args, kwargs, *fargs_):
    pass

## inital Code
def inital():
    global InitalBuiltinTypes
    for cls, _ in pairs(InitalBuiltinTypes):
        register_builtins_class(cls)
        BuiltinTypes[cls] = true
    InitalBuiltinTypes = nil

    _M["NotImplemented"] = NotImplementedType()
    _M["Ellipsis"] = EllipsisType()
    _M["None"] = NoneType()
    _M["True"] = bool(true)
    _M["False"] = bool(false)

    return true

inited = inital()
assert inited
##

## test code are here!
for x in _OP__ForIter__(tuple({int(1), int(2), int(3)})):
    print(x)

def Access_ForValue():
    __PC_ECMAXP_SETUP_ACCESS_FOR_VALUE(true)
    for test in pairs({1,2,3}):
        pass
    __PC_ECMAXP_SETUP_ACCESS_FOR_VALUE(false)
    lua.print("1", test)

Access_ForValue()

print(lua.format("%s", "test"))
print(str.mro())
print(object.mro())
print(_OP__Truediv__(int(3), int(6)))
print(int.mro())
print(object())
print(_OP__Add__(True, True))
print(_OP__Getitem__(list([int(1), int(2), int(3), int(4)]), int(0)))