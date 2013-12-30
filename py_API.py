if pyscripter: exit(__import__('pc').main())
### THE HACK FOR RUN py-API.py in pyscripts.
__PC_ECMAXP_ARE_THE_GOD_IN_THIS_WORLD("YES")
global _M # Already _M is local thing. :$

tick = os.sleep
if tick is nil:
    def tick():
        pass

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

tick();

## This table are weaktable.
ObjData = setmetatable({}, {"__mode":"k"}) # i=id, v=value, h=hash, d=data
ObjPCEX = setmetatable({}, {"__mode":"k"}) # small table for fast find
Obj_FromID = setmetatable({}, {"__mode":"v"})

BuiltinTypes = setmetatable({}, {"__mode":"k"})
## must cleaned after collectgarbage()

## pairs with weakref table are unsafe!
InitalBuiltinTypes = {}
##

metatable_events = [
    "__index",
    "__newindex",
    "__mode",
    "__call",
    "__metatable",
    "__tostring",
    "__len",
    "__gc",
    "__unm",
    "__add",
    "__sub",
    "__mul",
    "__div",
    "__mod",
    "__pow",
    "__concat",
    "__eq",
    "__lt",
    "__le",
]

metatable_events_rev = {}
for k, v in pairs(metatable_events):
    metatable_events_rev[v] = k

builtin_methods = __PC_ECMAXP_GET_OBJECT_ATTRS()
builtin_methods_rev = {}
for k, v in pairs(builtin_methods):
    builtin_methods_rev[v] = k

##assert builtin_methods[42] == '__rshift__'
##assert builtin_methods_rev["__pos__"] == 72

tick();

def __build_lua_class__(name, bases):
    obj = {}
    for _, c in pairs(bases):
        for k, v in pairs(c):
            obj[k] = v

    obj.__bases__ = bases
    obj.__name__ = name
    return obj

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
        return _OP.__lua__(obj)
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
        if obj_id is nil:
            obj_id = "?"

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

tick();

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
            tick();

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

tick();

def hide_class_from_seq(seq):
    new_seq = {}
    idx = 1

    for k, v in pairs(seq):
        if InitalBuiltinTypes[v] is not nil:
            new_seq[idx] = v
            idx += 1

    return new_seq

def setup_base_class(cls):
    tick();

    register_pyobj(cls)
    ObjData[cls].c = {}
    clsdata = ObjData[cls].c

    pcex = {}
    for k, v in pairs(cls):
        idx = builtin_methods_rev[k]
        if idx is not nil:
            pcex[idx] = v
        elif builtin_methods[k]:
            pcex[k] = v

    pcls = getmetatable(cls)

    ObjPCEX[cls] = pcex
    InitalBuiltinTypes[cls] = false

    clsdata.__mro__ = _C3_MRO.mro(cls)

    return cls

def setup_basic_class(cls):
    setup_base_class(cls, true)
    setmetatable(cls, type)

    return cls

def setup_hide_class(cls):
    InitalBuiltinTypes[cls] = nil
    return cls

def register_builtins_class(cls):
    clsdata = ObjData[cls].c
    if cls != object:
        clsdata.__base__ = object
    else:
        clsdata.__base__ = None

    clsdata.__name__ = str(cls.__name__)
    clsdata.__module__ = str("builtins")
    clsdata.__bases__ = tuple(hide_class_from_seq((cls.__bases__)))
    clsdata.__mro__ = tuple(hide_class_from_seq((clsdata.__mro__)))
    cls.__name__ = nil
    cls.__bases__ = nil

    InitalBuiltinTypes[cls] = true
    return cls

tick();

global _OP
_OP = {}

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

tick();

def  _OP__Is__(a, b):
    require_pyobj(a, b)
    return bool(ObjData[a].i == ObjData[b].i)
_OP.__Is__ = _OP__Is__

def _OP__IsNot__(a, b):
    return bool(not LObj(_OP.__Is__(a, b)))
_OP.__IsNot__ = _OP__IsNot__

def _OP__ForIter__(ret):
    return LObj(iter(ret))
_OP.__ForIter__ = _OP__ForIter__

def _OP__SetupGenFunc__(func):
    def func2():
        # TODO: add try~except and handle error!
        def body(*args):
            func(*args)

        return generator(coroutine.create(body))

    return func2
_OP__SetupGenFunc__ = _OP__SetupGenFunc__

_OP.__Yield__ = lua.yield_

def _OP__Call__(func, args, kwargs):
    pass
_OP.__Call__ = _OP__Call__

tick();
def _(name): return builtin_methods_rev[name]
__PC_ECMAXP_SET_QUICK_OBJECT_ATTRS(true)
## Basic Call (Part A)
_OP.__new__ = OP_Call(_('__new__'))
_OP.__init__ = OP_Call(_('__init__'))
_OP.__del__ = OP_Call(_('__del__'))
_OP.__repr__ = OP_Call(_('__repr__'))
_OP.__str__ = OP_Call(_('__str__'))
_OP.__bytes__ = OP_Call(_('__bytes__'))
_OP.__format__ = OP_Call(_('__format__'))
_OP.__lt__ = OP_Call(_('__lt__'))
_OP.__le__ = OP_Call(_('__le__'))
_OP.__eq__ = OP_Call(_('__eq__'))
_OP.__ne__ = OP_Call(_('__ne__'))
_OP.__gt__ = OP_Call(_('__gt__'))
_OP.__ge__ = OP_Call(_('__ge__'))
_OP.__hash__ = OP_Call(_('__hash__'))
_OP.__bool__ = OP_Call(_('__bool__'))
# TypeError: __bool__ should return bool, returned xxx
#: it must custom define for remove __bool__ from object
_OP.__getattr__ = OP_Call(_('__getattr__'))
_OP.__getattribute__ = OP_Call(_('__getattribute__'))
_OP.__setattr__ = OP_Call(_('__setattr__'))
_OP.__delattr__ = OP_Call(_('__delattr__'))
_OP.__dir__ = OP_Call(_('__dir__'))
_OP.__get__ = OP_Call(_('__get__'))
_OP.__set__ = OP_Call(_('__set__'))
_OP.__delete__ = OP_Call(_('__delete__'))
_OP.__slots__ = OP_Call(_('__slots__'))
_OP.__rawCall__ = OP_Call(_('__call__'))
_OP.__len__ = OP_Call(_('__len__'))
_OP.__getitem__ = OP_Call(_('__getitem__'))
_OP.__setitem__ = OP_Call(_('__setitem__'))
_OP.__delitem__ = OP_Call(_('__delitem__'))
_OP.__iter__ = OP_Call(_('__iter__'))
_OP.__reversed__ = OP_Call(_('__reversed__'))
_OP.__contains__ = OP_Call(_('__contains__'))

## Math Operation (A * B)
_OP.__add__ = OP_Math1(_('__add__'), _('__radd__'))
_OP.__sub__ = OP_Math1(_('__sub__'), _('__rsub__'))
_OP.__mul__ = OP_Math1(_('__mul__'), _('__rmul__'))
_OP.__truediv__ = OP_Math1(_('__truediv__'), _('__rtruediv__'))
_OP.__floordiv__ = OP_Math1(_('__floordiv__'), _('__rfloordiv__'))
_OP.__mod__ = OP_Math1(_('__mod__'), _('__rmod__'))
_OP.__divmod__ = OP_Math1(_('__divmod__'), _('__rdivmod__'))
_OP.__pow__ = OP_Math1_Pow(_('__pow__'), _('__rpow__'))
_OP.__lshift__ = OP_Math1(_('__lshift__'), _('__rlshift__'))
_OP.__rshift__ = OP_Math1(_('__rshift__'), _('__rrshift__'))
_OP.__and__ = OP_Math1(_('__and__'), _('__rand__'))
_OP.__xor__ = OP_Math1(_('__xor__'), _('__rxor__'))
_OP.__or__ = OP_Math1(_('__or__'), _('__ror__'))

## Math Operation (A *= B)
_OP.__iadd__ = OP_Math2(_('__iadd__'), _('__add__'), _('__radd__'))
_OP.__isub__ = OP_Math2(_('__isub__'), _('__sub__'), _('__rsub__'))
_OP.__imul__ = OP_Math2(_('__imul__'), _('__mul__'), _('__rmul__'))
_OP.__itruediv__ = OP_Math2(_('__itruediv__'), _('__truediv__'), _('__rtruediv__'))
_OP.__ifloordiv__ = OP_Math2(_('__ifloordiv__'), _('__floordiv__'), _('__rfloordiv__'))
_OP.__imod__ = OP_Math2(_('__imod__'), _('__mod__'), _('__rmod__'))
_OP.__ipow__ = OP_Math2_Pow(_('__ipow__'), _('__pow__'), _('__rpow__'))
_OP.__ilshift__ = OP_Math2(_('__ilshift__'), _('__lshift__'), _('__rlshift__'))
_OP.__irshift__ = OP_Math2(_('__irshift__'), _('__rshift__'), _('__rrshift__'))
_OP.__iand__ = OP_Math2(_('__iand__'), _('__and__'), _('__rand__'))
_OP.__ixor__ = OP_Math2(_('__ixor__'), _('__xor__'), _('__rxor__'))
_OP.__ior__ = OP_Math2(_('__ior__'), _('__or__'), _('__ror__'))

## Basic Call (Part B)
_OP.__neg__ = OP_Call(_('__neg__'))
_OP.__pos__ = OP_Call(_('__pos__'))
_OP.__abs__ = OP_Call(_('__abs__'))
_OP.__invert__ = OP_Call(_('__invert__'))
_OP.__complex__ = OP_Call(_('__complex__'))
_OP.__int__ = OP_Call(_('__int__'))
_OP.__float__ = OP_Call(_('__float__'))
_OP.__round__ = OP_Call(_('__round__'))
_OP.__index__ = OP_Call(_('__index__'))
_OP.__enter__ = OP_Call(_('__enter__'))
_OP.__exit__ = OP_Call(_('__exit__'))

## Extra Call
_OP.__lua__ = OP_Call(_('__lua__'))
__PC_ECMAXP_SET_QUICK_OBJECT_ATTRS(false)
tick();

## Builtins
__PC_ECMAXP_SETUP_AUTO_GLOBAL(true)
def repr(obj):
    if is_pyobj(obj):
        return _OP.__repr__(obj)
    else:
        return lua.format("%s(%s)", LUA_OBJ_TAG, tostring(obj))

def hash(obj):
    if is_pyobj(obj):
        return _OP.__hash__(obj)
    else:
        return -1

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

    for _, supercls in pairs(_OP.__lua__(mro)):
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

    for _, supercls in pairs(_OP.__lua__(mro)):
        require_pyobj(supercls)
        for k, target in pairs(targets):
            if supercls == target:
                return True
    return False

def id(obj):
    if is_pyobj(obj):
        return int(ObjData[obj].i)

    Fail_OP_Raw(obj, "__id!")

def dir(obj):
    return _OP.__dir__(obj)

def iter(ret):
    ret = _OP.__iter__(ret)
    if isinstance(ret, generator) == False:
        error(TypeError("iter are only accept generator!"))

    return ret

def len(obj):
    return _OP.__len__(obj)

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
        return _OP.__rawCall__(self, *args)

    def __index(self, key):
        return _OP.__getattribute__(self, key)

    def __newindex(self, key, value):
        return _OP.__setattr__(self, key, value)

    def __tostring(self):
        return lua.format("%s(%s)", PY_OBJ_TAG, LObj(repr(self)))

    def __new__(cls, *args):
        instance = {}
        register_pyobj(instance, _raw_id(instance))
        lua.setmetatable(instance, cls)
        _OP.__init__(instance, *args)

        return instance

    def __dir__(self):
        cls = getmetatable(self)
        ret = []

        for k, v in pairs(self):
            ret[k] = true;

        for k, v in pairs(cls):
            ret[k] = true

        ret2 = []
        idx = 1
        for k, v in pairs(ret):
            if not metatable_events_rev[k]:
                ret2[idx] = k; idx += 1

        ret = nil
        table.sort(ret2)

        ret3 = []
        for k, v in pairs(ret2):
            ret3[k] = str(v)

        ret2 = nil
        return list(ret3)

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

##        for k, v in pairs(self):
##            if _OP.__eq__(k, v):
##                return v

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
        return _OP.__repr__(self)

    def __repr__(self):
        mtable = getmetatable(self)
        name = mtable.__name__
        oid = id(self)
        oid = lua.format("000000000%X", LObj(oid))
        oid = lua.string.sub(oid, -BIT_WIDTH)

        return str(lua.format("<object %s at 0x%s>", LObj(name), oid))

    def __bool__(self):
        return True

tick();
global type
@setup_base_class
class type(object):
    def __getattribute__(cls, key):
        clsdata = ObjData[cls].c
        if clsdata is not nil:
            value = clsdata[key]
            if value is not nil:
                return value

        return object.__getattribute__(cls, key)

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
        _OP.__init__(instance, param)
        return instance

    def __str__(self):
        length = LObj(len(self.args))
        if length == 0:
            return str("")
        elif length == 1:
            return str(_OP.__getitem__(self.args, int(0)))

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
class TypeError(Exception):
    pass

@setup_basic_class
class UnstableException(Exception):
    pass

@setup_basic_class
class KeyError(Exception):
    pass

__PC_ECMAXP_SETUP_AUTO_GLOBAL(false)

@setup_basic_class
@setup_hide_class
class BuiltinConstType(object):
    def __new__(cls, *args):
        if not inited:
            instance = object.__new__(cls, *args)
            _OP.__init__(instance, *args)
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
        return str(_OP.__repr__(self))

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
        core = {}
        new = nil
        cur = core

        for k, v in pairs(value):
            new = {}
            new.v = v
            new.p = cur

            cur.n = new
            cur = new

        if core.n:
            # cut first's prev
            core.n.p = nil

        if new and new.p:
            # set last
            core.p = new

        LuaObject.__init__(self, core)

    def __getitem__(self, x):
        x = _OP.__index__(x)
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
        cur = ObjData[self].v.n
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

    def __len__(self):
        return int(lua.len(ObjData[self].v))

    def __getitem__(self, x):
        x = _OP.__index__(x)
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

        @_OP.__setupGenFunc__
        def body():
            nonlocal idx
            while value[idx] is not nil:
                _OP.__yield__(value[idx])
                idx += 1

        return body()

global dict
@setup_basic_class
class dict(LuaObject):
    def __init__(self, obj):
        LuaObject.__init__(self, {})
        ObjData[self].changed = false
        ObjData[self].length = 0
        dict.update(self, obj)

    def update(self, obj):
        for k, v in pairs(obj):
            _OP.__setitem__(self, k, v)

    def __setitem__(self, key, value):
        assert require_pyobj(key, value)
        data = ObjData[self]
        target = data.v
        hk = LObj(_OP.__hash__(key))

        if target[hk] is nil:
            data.changed = true
            data.length += 1
            target[hk] = [(key, value)]
            return

        line = target[hk]
        for a, t in pairs(line):
            if _OP.__eq__(key, t[1]) is True:
                t[1] = key
                t[2] = value
                return # TODO: Break
        else:
            data.changed = true
            data.length += 1
            line[lua.len(line) + 1] = {key, value}

    def __getitem__(self, key):
        assert require_pyobj(key)
        data = ObjData[self]
        target = data.v
        hk = LObj(_OP.__hash__(key))

        if target[hk] is nil:
            error(KeyError(key))

        line = target[hk]
        for a, t in pairs(line):
            if _OP.__eq__(key, t[1]) == True:
                return t[2]

        error(KeyError(key))

    def __lua__(self):
        pass

    def __repr__(self):
        target = ObjData[self].v
        ret = {}
        idx = 1

        sep = ""
        ret[idx] = "{"; idx += 1
        for _, line in pairs(target):
            for _, r in pairs(line):
                ret[idx] = sep; idx += 1
                ret[idx] = LObj(repr(r[1])); idx += 1
                ret[idx] = ": "; idx += 1
                ret[idx] = LObj(repr(r[2])); idx += 1
                sep = ", "

        ret[idx] = "}"; idx += 1

        return table.concat(ret)

#list = tuple # list are broken, wait until fix. (with linked list!)

global str
@setup_basic_class
class str(LuaObject):
    def __init__(self, value):
        if is_pyobj(value):
            value = _OP.__str__(value)
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

    def __eq__(self, other):
        return bool(ObjData[self].v == ObjData[other].v)

    def __ne__(self, other):
        return bool(ObjData[self].v != ObjData[other].v)

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
        return int(ObjData[self].v)

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
            value = _OP.__bool__(value)
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

    _G["NotImplemented"] = NotImplementedType()
    _G["Ellipsis"] = EllipsisType()
    _G["None"] = NoneType()
    _G["True"] = bool(true)
    _G["False"] = bool(false)

    return true

inited = inital()
assert inited
##

tick();

## test code are here!
c = 0

r = dict({int(1):int(2), int(3):int(4), int(1):int(3)})
tick();

print("!", _OP.__getitem__(r, int(3)))
tick();

print(a, b, c)
tick();

print(lua.format("%s", "test"))
tick();

print(_OP.__truediv__(int(3), int(6)))
tick();

print(int.mro())
tick();

print(dir(object()))
tick();

print("?", LObj(bool.__bases__))
tick();

print(_OP.__add__(True, True))
tick();

if computer:
    print("Python3 By EcmaXp :P")
    history = {}
    env = setmetatable(_G, {"__index":_ENV})
    while term.isAvailable():
        foreground = component.gpu.setForeground(0x00FF00)
        term.write("lua> ")
        component.gpu.setForeground(foreground)
        command = term.read(history)
        if command == nil:
            LUA_CODE("return")

        while lua.len(history) > 10:
            table.remove(history, 1)

        statement, result = load(command, "=stdin", "t", env)
        expression = load(lua.concat("return ", command), "=stdin", "t", env)
        code = expression or statement
        if code:
            result = table.pack(pcall(code))

        if not result[1] or result.n > 1:
            print(table.unpack(result, 2, result.n))
        else:
            print(result)