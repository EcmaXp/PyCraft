local _M = getfenv();
if pyscripter then -- [LINE 1]
  exit(__import__('pc').main()); -- [LINE 1]
end;
 -- [LINE 3]
local TAG = '[PY]'; -- [LINE 6]
lua = {}; -- [LINE 7]
local key, value;
for key, value in pairs(_G) do -- [LINE 8]
  lua[key] = value; -- [LINE 9]
end;
local builtins = 'builtins'; -- [LINE 11]
local OBJ_ID = 0; -- [LINE 12]
local inited = False; -- [LINE 13]
local ObjID = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 16]
local ObjValue = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 17]
local Obj_FromID = setmetatable({}, {['__mode'] = 'v'}); -- [LINE 18]
local IsBuiltinTypes = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 19]
local __PCEX__ = '__PCEX__'; -- [LINE 22]
local builtin_methods = {'__new__', '__init__', '__del__', '__repr__', '__str__', '__bytes__', '__format__', '__lt__', '__le__', '__eq__', '__ne__', '__gt__', '__ge__', '__hash__', '__bool__', '__getattr__', '__getattribute__', '__setattr__', '__delattr__', '__dir__', '__get__', '__set__', '__delete__', '__slots__', '__call__', '__len__', '__getitem__', '__setitem__', '__delitem__', '__iter__', '__reversed__', '__contains__', '__add__', '__sub__', '__mul__', '__truediv__', '__floordiv__', '__mod__', '__divmod__', '__pow__', '__lshift__', '__rshift__', '__and__', '__xor__', '__or__', '__radd__', '__rsub__', '__rmul__', '__rtruediv__', '__rfloordiv__', '__rmod__', '__rdivmod__', '__rpow__', '__rlshift__', '__rrshift__', '__rand__', '__rxor__', '__ror__', '__iadd__', '__isub__', '__imul__', '__itruediv__', '__ifloordiv__', '__imod__', '__ipow__', '__ilshift__', '__irshift__', '__iand__', '__ixor__', '__ior__', '__neg__', '__pos__', '__abs__', '__invert__', '__complex__', '__int__', '__float__', '__round__', '__index__', '__enter__', '__exit__', '__lua__'}; -- [LINE 23]
local builtin_methods_rev = {}; -- [LINE 25]
local k, v;
for k, v in pairs(builtin_methods) do -- [LINE 26]
  builtin_methods_rev[v] = k; -- [LINE 27]
end;
assert(builtin_methods[42] == '__rshift__'); -- [LINE 29]
assert(builtin_methods_rev['__pos__'] == 72); -- [LINE 30]
local function lua_len(obj)
  return #obj; -- [LINE 33]
end;
local function lua_concat(...)
  local args = {...};
  local r = ''; -- [LINE 36]
  local _, x;
  for _, x in pairs(args) do -- [LINE 37]
    x = tostring(x); -- [LINE 38]
    r = r..x; -- [LINE 39]
  end;
  return r; -- [LINE 41]
end;
lua.len = lua_len; -- [LINE 43]
lua.concat = lua_concat; -- [LINE 44]
local function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 47]
    error('This is not number', 2); -- [LINE 48]
  end;
  return math.floor(num) ~= num; -- [LINE 50]
end;
local function error(msg, level)
  if level == nil then -- [LINE 53]
    level = 1; -- [LINE 54]
  end;
  level = (level + 1); -- [LINE 56]
  lua.error(lua.concat(TAG, ' ', msg), level); -- [LINE 57]
end;
local function require_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 60]
    if value == nil then -- [LINE 61]
      error('SystemError: Not Enough Item'); -- [LINE 62]
    end;
  end;
  return True; -- [LINE 64]
end;
local function nonrequire_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 67]
    if value ~= nil then -- [LINE 68]
      error('SystemError: Not Enough Item'); -- [LINE 69]
    end;
  end;
  return True; -- [LINE 71]
end;
function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 74]
    error('This is not number', 2); -- [LINE 75]
  end;
  return math.floor(num) ~= num; -- [LINE 77]
end;
local function is_pyobj(obj)
  return ObjID[obj] ~= nil; -- [LINE 80]
end;
local function to_pyobj(obj)
  if is_pyobj(obj) then -- [LINE 83]
    return obj; -- [LINE 84]
  else
    return LuaObject(obj); -- [LINE 86]
  end;
end;
local function to_luaobj(obj)
  if is_pyobj(obj) then -- [LINE 100]
    return _OP__Lua__(obj); -- [LINE 101]
  else
    return obj; -- [LINE 103]
  end;
end;
local function require_pyobj(...)
  local objs = {...};
  local idx, obj;
  for idx, obj in pairs(objs) do -- [LINE 106]
    if not is_pyobj(obj) then -- [LINE 107]
      lua.print(lua.type(obj), obj); -- [LINE 108]
      error('Require python object.'); -- [LINE 109]
    end;
  end;
  return true; -- [LINE 111]
end;
local function register_pyobj(obj)
  OBJ_ID = (OBJ_ID + 1); -- [LINE 115]
  local obj_id = OBJ_ID; -- [LINE 116]
  ObjID[obj] = obj_id; -- [LINE 118]
  Obj_FromID[obj_id] = obj; -- [LINE 119]
  return obj; -- [LINE 120]
end;
local function setup_basic_class(cls)
  rawset(cls, __PCEX__, nil); -- [LINE 123]
  local pcex = {}; -- [LINE 125]
  local k, v;
  for k, v in pairs(cls) do -- [LINE 126]
    local idx = builtin_methods_rev[k]; -- [LINE 127]
    if idx ~= nil then -- [LINE 128]
      pcex[idx] = v; -- [LINE 129]
    end;
  end;
  rawset(cls, __PCEX__, pcex); -- [LINE 131]
  register_pyobj(cls); -- [LINE 132]
  return cls; -- [LINE 133]
end;
local function register_builtins_class(cls, ...)
  local bases = {...};
  local mro = {}; -- [LINE 136]
  local idx = 1; -- [LINE 137]
  for i = #bases, 1, -1 do --; -- [LINE 138]
  if true then -- [LINE 139]
    local base = bases[i]; -- [LINE 140]
    mro[idx] = base; -- [LINE 141]
    idx = (idx + 1); -- [LINE 142]
  end;
  end; -- [LINE 143]
  mro[idx] = cls; -- [LINE 145]
  rawset(cls, '__module__', str('builtins')); -- [LINE 146]
  rawset(cls, '__mro__', tuple(mro)); -- [LINE 147]
  IsBuiltinTypes[cls] = true; -- [LINE 148]
  return cls; -- [LINE 149]
end;
local function Fail_OP(a, ax)
  error(lua.concat(to_luaobj(repr(a)), ' are not support ', methods[ax])); -- [LINE 152]
end;
local function Fail_OP_Raw(a, raw_ax)
  error(lua.concat(to_luaobj(repr(a)), ' are not support ', raw_ax)); -- [LINE 155]
end;
local function Fail_OP_Math_Raw(a, b, raw_ax)
  error(lua.concat('Not support ', to_luaobj(repr(a)), ' ', raw_ax, ' ', to_luaobj(repr(b)))); -- [LINE 158]
end;
local function Fail_OP_Math(a, b, ax, extra)
  if extra == nil then -- [LINE 161]
    extra = ''; -- [LINE 162]
  else
    extra = lua.concat(' ', extra); -- [LINE 164]
  end;
  error(lua.concat('Not support ', to_luaobj(repr(a)), ' ', methods[ax], ' ', to_luaobj(repr(b)), extra)); -- [LINE 166]
end;
local function Fail_OP_Math_Pow(a, b, ax, c)
  local extra = ''; -- [LINE 169]
  if c then -- [LINE 170]
    extra = lua.concat('% ', to_luaobj(repr(c))); -- [LINE 171]
  end;
  Fail_OP_Math(a, b, ax, c); -- [LINE 173]
end;
function repr(obj)
  if is_pyobj(obj) then -- [LINE 177]
    return _OP__Repr__(obj); -- [LINE 178]
  else
    return lua.concat('@(', tostring(obj), ')'); -- [LINE 180]
  end;
end;
function print(...)
  local args = {...};
  local write = lua.io.write; -- [LINE 184]
  local sep = ' '; -- [LINE 185]
  local _, arg;
  for _, arg in pairs(args) do -- [LINE 187]
    if is_pyobj(arg) then -- [LINE 188]
      arg = str(arg); -- [LINE 189]
    else
      arg = repr(arg); -- [LINE 191]
    end;
    arg = to_luaobj(arg); -- [LINE 193]
    write(arg); -- [LINE 194]
    write(sep); -- [LINE 195]
  end;
  write('\n'); -- [LINE 197]
end;
function isinstance(cls, targets)
  require_pyobj(obj); -- [LINE 201]
  if type(cls) ~= type then -- [LINE 203]
    cls = type(obj); -- [LINE 204]
  end;
  local mro = cls.mro(); -- [LINE 206]
  assert(type(mro) == tuple); -- [LINE 207]
  local _, supercls;
  for _, supercls in pairs(mro.value) do -- [LINE 209]
    require_pyobj(supercls); -- [LINE 210]
    if supercls == targets then -- [LINE 211]
      return True; -- [LINE 212]
    end;
  end;
  return False; -- [LINE 214]
end;
local function issubclass(cls, targets)
  require_pyobj(obj); -- [LINE 217]
  if type(cls) ~= type then -- [LINE 219]
    error('issubclass() arg 1 must be a class'); -- [LINE 220]
  end;
  local mro = cls.mro(); -- [LINE 222]
  assert(type(mro) == tuple); -- [LINE 223]
  local _, supercls;
  for _, supercls in pairs(ObjValue[mro]) do -- [LINE 225]
    require_pyobj(supercls); -- [LINE 226]
    if supercls == targets then -- [LINE 227]
      return True; -- [LINE 228]
    end;
  end;
  return False; -- [LINE 230]
end;
function id(obj)
  if is_pyobj(obj) then -- [LINE 234]
    return int(ObjID[obj]); -- [LINE 235]
  end;
  Fail_OP_Raw(obj, '__id__!'); -- [LINE 237]
end;
local function OP_Call(ax)
  local function func(a, ...)
    local args = {...};
    assert(require_pyobj(a)); -- [LINE 241]
    local f = rawget(getmetatable(a), __PCEX__)[ax]; -- [LINE 242]
    if f then -- [LINE 243]
      return f(a, ...); -- [LINE 244]
    end;
    Fail_OP(a, ax); -- [LINE 246]
  end;
  return func; -- [LINE 247]
end;
local function OP_Math2(ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 251]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 252]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 253]
    local f = am[ax]; -- [LINE 255]
    if f then -- [LINE 256]
      local ret = f(a, b); -- [LINE 257]
      if ret ~= NotImplemented then -- [LINE 258]
        return ret; -- [LINE 258]
      end;
    end;
    f = bm[bx]; -- [LINE 260]
    if f then -- [LINE 261]
      ret = f(b, a); -- [LINE 262]
      if ret ~= NotImplemented then -- [LINE 263]
        return ret; -- [LINE 263]
      end;
    end;
    Fail_OP_Math(a, b, ax); -- [LINE 265]
  end;
  return func; -- [LINE 267]
end;
local function OP_Math3(cx, ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 271]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 272]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 273]
    local f = am[cx]; -- [LINE 275]
    if f then -- [LINE 276]
      local ret = f(a, b); -- [LINE 277]
      if ret ~= NotImplemented then -- [LINE 278]
        return ret; -- [LINE 278]
      end;
    end;
    f = am[ax]; -- [LINE 281]
    if f then -- [LINE 282]
      ret = f(a, b); -- [LINE 283]
      if ret ~= NotImplemented then -- [LINE 284]
        return ret; -- [LINE 284]
      end;
    end;
    f = bm[bx]; -- [LINE 286]
    if f then -- [LINE 287]
      ret = f(b, a); -- [LINE 288]
      if ret ~= NotImplemented then -- [LINE 289]
        return ret; -- [LINE 289]
      end;
    end;
    Fail_OP_Math(a, b, cx); -- [LINE 291]
  end;
  return func; -- [LINE 293]
end;
local function OP_Math2_Pow(ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 297]
    assert(require_pyobj(c) or c == nil); -- [LINE 298]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 299]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 300]
    local f = am[ax]; -- [LINE 302]
    if f then -- [LINE 303]
      local ret = f(a, b, c); -- [LINE 304]
      if ret ~= NotImplemented then -- [LINE 305]
        return ret; -- [LINE 305]
      end;
    end;
    if c ~= nil then -- [LINE 307]
      f = bm[bx]; -- [LINE 312]
      if f then -- [LINE 313]
        ret = f(b, a); -- [LINE 314]
        if ret ~= NotImplemented then -- [LINE 315]
          return ret; -- [LINE 315]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 317]
  end;
  return func; -- [LINE 319]
end;
local function OP_Math3_Pow(cx, ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 323]
    assert(require_pyobj(c) or c == nil); -- [LINE 324]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 325]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 326]
    local f = am[cx]; -- [LINE 328]
    if f then -- [LINE 329]
      local ret = f(a, b, c); -- [LINE 330]
      if ret ~= NotImplemented then -- [LINE 331]
        return ret; -- [LINE 331]
      end;
    end;
    f = am[ax]; -- [LINE 333]
    if f then -- [LINE 334]
      ret = f(a, b, c); -- [LINE 335]
      if ret ~= NotImplemented then -- [LINE 336]
        return ret; -- [LINE 336]
      end;
    end;
    if c ~= nil then -- [LINE 338]
      f = bm[bx]; -- [LINE 339]
      if f then -- [LINE 340]
        ret = f(b, a); -- [LINE 341]
        if ret ~= NotImplemented then -- [LINE 342]
          return ret; -- [LINE 342]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 344]
  end;
  return func; -- [LINE 346]
end;
function _OP__Is__(a, b)
  require_pyobj(a, b); -- [LINE 350]
  return ObjID[a] == ObjID[b]; -- [LINE 351]
end;
function _OP__IsNot__(a, b)
  return not _OP__Is__(a, b); -- [LINE 354]
end;
local function _(name)
  return builtin_methods_rev[name]; -- [LINE 356]
end;
 -- [LINE 357]
_OP__New__ = OP_Call(_('__new__')); -- [LINE 359]
_OP__Init__ = OP_Call(_('__init__')); -- [LINE 360]
_OP__Del__ = OP_Call(_('__del__')); -- [LINE 361]
_OP__Repr__ = OP_Call(_('__repr__')); -- [LINE 362]
_OP__Str__ = OP_Call(_('__str__')); -- [LINE 363]
_OP__Bytes__ = OP_Call(_('__bytes__')); -- [LINE 364]
_OP__Format__ = OP_Call(_('__format__')); -- [LINE 365]
_OP__Lt__ = OP_Call(_('__lt__')); -- [LINE 366]
_OP__Le__ = OP_Call(_('__le__')); -- [LINE 367]
_OP__Eq__ = OP_Call(_('__eq__')); -- [LINE 368]
_OP__Ne__ = OP_Call(_('__ne__')); -- [LINE 369]
_OP__Gt__ = OP_Call(_('__gt__')); -- [LINE 370]
_OP__Ge__ = OP_Call(_('__ge__')); -- [LINE 371]
_OP__Hash__ = OP_Call(_('__hash__')); -- [LINE 372]
_OP__Bool__ = OP_Call(_('__bool__')); -- [LINE 373]
_OP__Getattr__ = OP_Call(_('__getattr__')); -- [LINE 374]
_OP__Getattribute__ = OP_Call(_('__getattribute__')); -- [LINE 375]
_OP__Setattr__ = OP_Call(_('__setattr__')); -- [LINE 376]
_OP__Delattr__ = OP_Call(_('__delattr__')); -- [LINE 377]
_OP__Dir__ = OP_Call(_('__dir__')); -- [LINE 378]
_OP__Get__ = OP_Call(_('__get__')); -- [LINE 379]
_OP__Set__ = OP_Call(_('__set__')); -- [LINE 380]
_OP__Delete__ = OP_Call(_('__delete__')); -- [LINE 381]
_OP__Slots__ = OP_Call(_('__slots__')); -- [LINE 382]
_OP__Call__ = OP_Call(_('__call__')); -- [LINE 383]
_OP__Len__ = OP_Call(_('__len__')); -- [LINE 384]
_OP__Getitem__ = OP_Call(_('__getitem__')); -- [LINE 385]
_OP__Setitem__ = OP_Call(_('__setitem__')); -- [LINE 386]
_OP__Delitem__ = OP_Call(_('__delitem__')); -- [LINE 387]
_OP__Iter__ = OP_Call(_('__iter__')); -- [LINE 388]
_OP__Reversed__ = OP_Call(_('__reversed__')); -- [LINE 389]
_OP__Contains__ = OP_Call(_('__contains__')); -- [LINE 390]
_OP__Add__ = OP_Math2(_('__add__'), _('__radd__')); -- [LINE 393]
_OP__Sub__ = OP_Math2(_('__sub__'), _('__rsub__')); -- [LINE 394]
_OP__Mul__ = OP_Math2(_('__mul__'), _('__rmul__')); -- [LINE 395]
_OP__Truediv__ = OP_Math2(_('__truediv__'), _('__rtruediv__')); -- [LINE 396]
_OP__Floordiv__ = OP_Math2(_('__floordiv__'), _('__rfloordiv__')); -- [LINE 397]
_OP__Mod__ = OP_Math2(_('__mod__'), _('__rmod__')); -- [LINE 398]
_OP__Divmod__ = OP_Math2(_('__divmod__'), _('__rdivmod__')); -- [LINE 399]
_OP__Pow__ = OP_Math2_Pow(_('__pow__'), _('__rpow__')); -- [LINE 400]
_OP__Lshift__ = OP_Math2(_('__lshift__'), _('__rlshift__')); -- [LINE 401]
_OP__Rshift__ = OP_Math2(_('__rshift__'), _('__rrshift__')); -- [LINE 402]
_OP__And__ = OP_Math2(_('__and__'), _('__rand__')); -- [LINE 403]
_OP__Xor__ = OP_Math2(_('__xor__'), _('__rxor__')); -- [LINE 404]
_OP__Or__ = OP_Math2(_('__or__'), _('__ror__')); -- [LINE 405]
_OP__Iadd__ = OP_Math3(_('__iadd__'), _('__add__'), _('__radd__')); -- [LINE 408]
_OP__Isub__ = OP_Math3(_('__isub__'), _('__sub__'), _('__rsub__')); -- [LINE 409]
_OP__Imul__ = OP_Math3(_('__imul__'), _('__mul__'), _('__rmul__')); -- [LINE 410]
_OP__Itruediv__ = OP_Math3(_('__itruediv__'), _('__truediv__'), _('__rtruediv__')); -- [LINE 411]
_OP__Ifloordiv__ = OP_Math3(_('__ifloordiv__'), _('__floordiv__'), _('__rfloordiv__')); -- [LINE 412]
_OP__Imod__ = OP_Math3(_('__imod__'), _('__mod__'), _('__rmod__')); -- [LINE 413]
_OP__Ipow__ = OP_Math3_Pow(_('__ipow__'), _('__pow__'), _('__rpow__')); -- [LINE 414]
_OP__Ilshift__ = OP_Math3(_('__ilshift__'), _('__lshift__'), _('__rlshift__')); -- [LINE 415]
_OP__Irshift__ = OP_Math3(_('__irshift__'), _('__rshift__'), _('__rrshift__')); -- [LINE 416]
_OP__Iand__ = OP_Math3(_('__iand__'), _('__and__'), _('__rand__')); -- [LINE 417]
_OP__Ixor__ = OP_Math3(_('__ixor__'), _('__xor__'), _('__rxor__')); -- [LINE 418]
_OP__Ior__ = OP_Math3(_('__ior__'), _('__or__'), _('__ror__')); -- [LINE 419]
_OP__Neg__ = OP_Call(_('__neg__')); -- [LINE 422]
_OP__Pos__ = OP_Call(_('__pos__')); -- [LINE 423]
_OP__Abs__ = OP_Call(_('__abs__')); -- [LINE 424]
_OP__Invert__ = OP_Call(_('__invert__')); -- [LINE 425]
_OP__Complex__ = OP_Call(_('__complex__')); -- [LINE 426]
_OP__Int__ = OP_Call(_('__int__')); -- [LINE 427]
_OP__Float__ = OP_Call(_('__float__')); -- [LINE 428]
_OP__Round__ = OP_Call(_('__round__')); -- [LINE 429]
_OP__Index__ = OP_Call(_('__index__')); -- [LINE 430]
_OP__Enter__ = OP_Call(_('__enter__')); -- [LINE 431]
_OP__Exit__ = OP_Call(_('__exit__')); -- [LINE 432]
_OP__Lua__ = OP_Call(_('__lua__')); -- [LINE 435]
 -- [LINE 436]
_ = nil; -- [LINE 437]
object = (function(_G) -- (class object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  __name__ = 'object';
  function __init__(self)
  end;
  setfenv(__init__, _G);
  function __call(self, ...)
    local args = {...};
    return _OP__Call__(self, ...); -- [LINE 446]
  end;
  setfenv(__call, _G);
  function __index(self, key)
    return _OP__Getattribute__(self, key); -- [LINE 449]
  end;
  setfenv(__index, _G);
  function __newindex(self, key, value)
    return _OP__Setattr__(self, key, value); -- [LINE 452]
  end;
  setfenv(__newindex, _G);
  function __tostring(self)
    return lua.concat('#(', to_luaobj(repr(self)), ')'); -- [LINE 455]
  end;
  setfenv(__tostring, _G);
  function __new__(cls, ...)
    local args = {...};
    local instance = register_pyobj({}); -- [LINE 458]
    lua.setmetatable(instance, cls); -- [LINE 459]
    _OP__Init__(instance, ...); -- [LINE 460]
    return instance; -- [LINE 462]
  end;
  setfenv(__new__, _G);
  function __getattribute__(self, k)
    local v = rawget(self, k); -- [LINE 465]
    if v ~= nil then -- [LINE 466]
      return v; -- [LINE 467]
    end;
    local mt = getmetatable(self); -- [LINE 469]
    v = rawget(mt, k); -- [LINE 470]
    if v ~= nil then -- [LINE 471]
      if lua.type(v) == 'function' then -- [LINE 472]
        return (function(...) return v(self, unpack({...})) end); -- [LINE 473]
      else
        return v; -- [LINE 475]
      end;
    end;
    error(lua.concat("Not found '", k, "' attribute.")); -- [LINE 477]
  end;
  setfenv(__getattribute__, _G);
  function __setattr__(self, key, value)
    if IsBuiltinTypes[type(self)] and inited then -- [LINE 480]
      error("TypeError: can't set attributes of built-in/extension type 'object'"); -- [LINE 481]
    end;
    rawset(self, key, value); -- [LINE 484]
  end;
  setfenv(__setattr__, _G);
  function __str__(self)
    return _OP__Repr__(self); -- [LINE 487]
  end;
  setfenv(__str__, _G);
  function __repr__(self)
    local mtable = getmetatable(self); -- [LINE 490]
    return str(concat('<object ', mtable.__name__, ' at ', tostring(self.__id), '>')); -- [LINE 491]
  end;
  setfenv(__repr__, _G);
  return getfenv();
end)(getfenv());
object = setup_basic_class(object);
type = (function(_G) -- (class type:object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'type';
  function __call__(cls, ...)
    local args = {...};
    local instance = cls.__new__(cls, ...); -- [LINE 497]
    register_pyobj(instance); -- [LINE 498]
    return instance; -- [LINE 500]
  end;
  setfenv(__call__, _G);
  function __repr__(cls)
    return str(lua.concat("<class '", cls.__name__, "'>")); -- [LINE 503]
  end;
  setfenv(__repr__, _G);
  function mro(cls)
    return cls.__mro__; -- [LINE 506]
  end;
  setfenv(mro, _G);
  return getfenv();
end)(getfenv());
type = setup_basic_class(type);
local ptype = (function(_G) -- (class ptype:type)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({type}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'ptype';
  function __call__(cls, ...)
    local args = {...};
    if lua.len(args) == 1 then -- [LINE 511]
      require_pyobj(args[1]); -- [LINE 512]
      return getmetatable(args[1]); -- [LINE 513]
    elseif lua.len(args) == 3 then -- [LINE 514]
    else
      error('Unexcepted arguments.'); -- [LINE 517]
    end;
  end;
  setfenv(__call__, _G);
  return getfenv();
end)(getfenv());
ptype = setup_basic_class(ptype);
setmetatable(object, type); -- [LINE 519]
setmetatable(type, ptype); -- [LINE 520]
setmetatable(ptype, ptype); -- [LINE 521]
local BaseException = (function(_G) -- (class BaseException:object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'BaseException';
  return getfenv();
end)(getfenv());
setmetatable(BaseException, type);
BaseException = setup_basic_class(BaseException);
local LuaObject = (function(_G) -- (class LuaObject:object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'LuaObject';
  LuaObject = true; -- [LINE 530]
  function __init__(self, obj)
    local mtable = getmetatable(obj); -- [LINE 534]
    if mtable and rawget(mtable, 'LuaObject') then -- [LINE 535]
      obj = to_luaobj(obj); -- [LINE 536]
    end;
    ObjValue[self] = obj; -- [LINE 538]
  end;
  setfenv(__init__, _G);
  function __str__(self)
    return str(_OP__Repr__(self)); -- [LINE 541]
  end;
  setfenv(__str__, _G);
  function __repr__(self)
    return str(tostring(ObjValue[self])); -- [LINE 544]
  end;
  setfenv(__repr__, _G);
  function __lua__(self)
    return ObjValue[self]; -- [LINE 547]
  end;
  setfenv(__lua__, _G);
  return getfenv();
end)(getfenv());
setmetatable(LuaObject, type);
LuaObject = setup_basic_class(LuaObject);
local LuaValueOnlySequance = (function(_G) -- (class LuaValueOnlySequance:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'LuaValueOnlySequance';
  function __init__(self, value)
    if is_pyobj(value) then -- [LINE 552]
      self.check_type(value); -- [LINE 553]
    end;
    ObjValue[self] = value; -- [LINE 555]
  end;
  setfenv(__init__, _G);
  function check_type(self, value)
    if type(value) == 'table' then -- [LINE 558]
    elseif value[lua.len(value)] == nil then -- [LINE 559]
    elseif value[1] == nil then -- [LINE 560]
    elseif value[0] ~= nil then -- [LINE 561]
    else
      return true; -- [LINE 563]
    end;
    return false; -- [LINE 565]
  end;
  setfenv(check_type, _G);
  function make_repr(self, s, e)
    local ret = {}; -- [LINE 568]
    local idx = 1; -- [LINE 569]
    local sep = ''; -- [LINE 571]
    ret[idx] = s; -- [LINE 572]
    idx = (idx + 1); -- [LINE 572]
    local k, v;
    for k, v in pairs(ObjValue[self]) do -- [LINE 573]
      ret[idx] = sep; -- [LINE 574]
      idx = (idx + 1); -- [LINE 574]
      ret[idx] = to_luaobj(repr(v)); -- [LINE 575]
      idx = (idx + 1); -- [LINE 575]
      sep = ', '; -- [LINE 576]
    end;
    ret[idx] = e; -- [LINE 578]
    idx = (idx + 1); -- [LINE 578]
    return table.concat(ret); -- [LINE 580]
  end;
  setfenv(make_repr, _G);
  return getfenv();
end)(getfenv());
setmetatable(LuaValueOnlySequance, type);
LuaValueOnlySequance = setup_basic_class(LuaValueOnlySequance);
list = (function(_G) -- (class list:LuaValueOnlySequance)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaValueOnlySequance}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'list';
  function __repr__(self)
    return self.make_repr('[', ']'); -- [LINE 586]
  end;
  setfenv(__repr__, _G);
  function __setattr__(self, key, value)
    error('Not allowed'); -- [LINE 589]
  end;
  setfenv(__setattr__, _G);
  return getfenv();
end)(getfenv());
setmetatable(list, type);
list = setup_basic_class(list);
tuple = (function(_G) -- (class tuple:LuaValueOnlySequance)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaValueOnlySequance}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'tuple';
  function __repr__(self)
    return self.make_repr('(', ')'); -- [LINE 595]
  end;
  setfenv(__repr__, _G);
  function __setattr__(self, key, value)
    error('Not allowed'); -- [LINE 598]
  end;
  setfenv(__setattr__, _G);
  return getfenv();
end)(getfenv());
setmetatable(tuple, type);
tuple = setup_basic_class(tuple);
str = (function(_G) -- (class str:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'str';
  function __init__(self, value)
    if is_pyobj(value) then -- [LINE 604]
      value = _OP__Str__(value); -- [LINE 605]
      value = to_luaobj(value); -- [LINE 606]
    end;
    ObjValue[self] = value; -- [LINE 608]
  end;
  setfenv(__init__, _G);
  function __str__(self)
    return self; -- [LINE 611]
  end;
  setfenv(__str__, _G);
  function __repr__(self)
    return str(lua.concat("'", ObjValue[self], "'")); -- [LINE 614]
  end;
  setfenv(__repr__, _G);
  return getfenv();
end)(getfenv());
setmetatable(str, type);
str = setup_basic_class(str);
local function make_bool(value)
  local instance = {['value'] = value}; -- [LINE 617]
  register_pyobj(instance); -- [LINE 618]
  setmetatable(instance, bool); -- [LINE 619]
  return instance; -- [LINE 621]
end;
bool = (function(_G) -- (class bool:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'bool';
  function __new__(cls, value)
    if not inited then -- [LINE 627]
      local instance = object.__new__(cls); -- [LINE 628]
      instance.value = value; -- [LINE 629]
      return instance; -- [LINE 630]
    end;
    if is_pyobj(value) then -- [LINE 632]
      value = _OP__Bool__(value); -- [LINE 633]
    else
      value = value and true or false; -- [LINE 636]
    end;
    if value == true then -- [LINE 638]
      return True; -- [LINE 639]
    elseif value == false then -- [LINE 640]
      return False; -- [LINE 641]
    elseif is_pyobj(value) and type(value) == bool then -- [LINE 642]
      return value; -- [LINE 643]
    end;
    error('__Bool__ are returned unknown value.'); -- [LINE 645]
  end;
  setfenv(__new__, _G);
  function __repr__(self)
    if self.value == true then -- [LINE 648]
      return str('True'); -- [LINE 649]
    elseif self.value == false then -- [LINE 650]
      return str('False'); -- [LINE 651]
    end;
  end;
  setfenv(__repr__, _G);
  return getfenv();
end)(getfenv());
setmetatable(bool, type);
bool = setup_basic_class(bool);
int = (function(_G) -- (class int:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'int';
  function __add__(self, other)
    return int((ObjValue[self] + ObjValue[other])); -- [LINE 659]
  end;
  setfenv(__add__, _G);
  return getfenv();
end)(getfenv());
setmetatable(int, type);
int = setup_basic_class(int);
dict = (function(_G) -- (class dict:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'dict';
  return getfenv();
end)(getfenv());
setmetatable(dict, type);
dict = setup_basic_class(dict);
register_builtins_class(object); -- [LINE 667]
register_builtins_class(type, object); -- [LINE 668]
register_builtins_class(list, object); -- [LINE 669]
register_builtins_class(str, object); -- [LINE 670]
register_builtins_class(int, object); -- [LINE 671]
register_builtins_class(dict, object); -- [LINE 672]
True = bool(true); -- [LINE 673]
False = bool(false); -- [LINE 674]
inited = True; -- [LINE 675]
local function table_len(x)
  local count = 0; -- [LINE 681]
  local k, v;
  for k, v in pairs(x) do -- [LINE 682]
    count = (count + 1); -- [LINE 682]
  end;
  return count; -- [LINE 683]
end;
local x = list({int(1), int(2), int(3)}); -- [LINE 685]
local y = int(5); -- [LINE 686]
local z = int(7); -- [LINE 687]
print(x); -- [LINE 689]
print(True == nil); -- [LINE 690]
print(True); -- [LINE 691]
print(issubclass(int, object)); -- [LINE 692]
print(int.mro()); -- [LINE 693]
print(_OP__Add__(y, z)); -- [LINE 694]
