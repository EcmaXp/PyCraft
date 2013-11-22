local _M = getfenv();
if pyscripter then -- [LINE 1]
  exit(__import__('pc').main()); -- [LINE 1]
end;
 -- [LINE 3]
lua = {}; -- [LINE 6]
lua.len = (function(obj) return #obj end); -- [LINE 7]
lua.concat = (function(...) return table.concat({...}) end); -- [LINE 8]
local key, value;
for key, value in pairs(_G) do -- [LINE 9]
  lua[key] = value; -- [LINE 10]
end;
local TAG = '[PY]'; -- [LINE 12]
local ObjLastID = 0; -- [LINE 13]
local inited = False; -- [LINE 14]
local __PCEX__ = '__PCEX__'; -- [LINE 16]
local builtins = 'builtins'; -- [LINE 17]
local ObjID = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 20]
local ObjValue = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 21]
local Obj_FromID = setmetatable({}, {['__mode'] = 'v'}); -- [LINE 22]
local IsBuiltinTypes = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 23]
local builtin_methods = {'__new__', '__init__', '__del__', '__repr__', '__str__', '__bytes__', '__format__', '__lt__', '__le__', '__eq__', '__ne__', '__gt__', '__ge__', '__hash__', '__bool__', '__getattr__', '__getattribute__', '__setattr__', '__delattr__', '__dir__', '__get__', '__set__', '__delete__', '__slots__', '__call__', '__len__', '__getitem__', '__setitem__', '__delitem__', '__iter__', '__reversed__', '__contains__', '__add__', '__sub__', '__mul__', '__truediv__', '__floordiv__', '__mod__', '__divmod__', '__pow__', '__lshift__', '__rshift__', '__and__', '__xor__', '__or__', '__radd__', '__rsub__', '__rmul__', '__rtruediv__', '__rfloordiv__', '__rmod__', '__rdivmod__', '__rpow__', '__rlshift__', '__rrshift__', '__rand__', '__rxor__', '__ror__', '__iadd__', '__isub__', '__imul__', '__itruediv__', '__ifloordiv__', '__imod__', '__ipow__', '__ilshift__', '__irshift__', '__iand__', '__ixor__', '__ior__', '__neg__', '__pos__', '__abs__', '__invert__', '__complex__', '__int__', '__float__', '__round__', '__index__', '__enter__', '__exit__', '__lua__'}; -- [LINE 26]
local builtin_methods_rev = {}; -- [LINE 27]
local k, v;
for k, v in pairs(builtin_methods) do -- [LINE 28]
  builtin_methods_rev[v] = k; -- [LINE 29]
end;
assert(builtin_methods[42] == '__rshift__'); -- [LINE 31]
assert(builtin_methods_rev['__pos__'] == 72); -- [LINE 32]
local function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 35]
    error('This is not number', 2); -- [LINE 36]
  end;
  return math.floor(num) ~= num; -- [LINE 38]
end;
local function error(msg, level)
  if level == nil then -- [LINE 41]
    level = 1; -- [LINE 42]
  end;
  level = (level + 1); -- [LINE 44]
  lua.error(lua.concat(TAG, ' ', msg), level); -- [LINE 45]
end;
local function require_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 48]
    if value == nil then -- [LINE 49]
      error('SystemError: Not Enough Item'); -- [LINE 50]
    end;
  end;
  return True; -- [LINE 52]
end;
local function nonrequire_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 55]
    if value ~= nil then -- [LINE 56]
      error('SystemError: Not Enough Item'); -- [LINE 57]
    end;
  end;
  return True; -- [LINE 59]
end;
function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 62]
    error('This is not number', 2); -- [LINE 63]
  end;
  return math.floor(num) ~= num; -- [LINE 65]
end;
local function is_pyobj(obj)
  return ObjID[obj] ~= nil; -- [LINE 68]
end;
local function to_pyobj(obj)
  if is_pyobj(obj) then -- [LINE 71]
    return obj; -- [LINE 72]
  else
    return LuaObject(obj); -- [LINE 74]
  end;
end;
local function to_luaobj(obj)
  if is_pyobj(obj) then -- [LINE 88]
    return _OP__Lua__(obj); -- [LINE 89]
  else
    return obj; -- [LINE 91]
  end;
end;
local function require_pyobj(...)
  local objs = {...};
  local idx, obj;
  for idx, obj in pairs(objs) do -- [LINE 94]
    if not is_pyobj(obj) then -- [LINE 95]
      lua.print(lua.type(obj), obj); -- [LINE 96]
      error('Require python object.'); -- [LINE 97]
    end;
  end;
  return true; -- [LINE 99]
end;
local function register_pyobj(obj)
  ObjLastID = (ObjLastID + 1); -- [LINE 103]
  local obj_id = ObjLastID; -- [LINE 104]
  ObjID[obj] = obj_id; -- [LINE 106]
  Obj_FromID[obj_id] = obj; -- [LINE 107]
  return obj; -- [LINE 108]
end;
local function setup_base_class(cls)
  rawset(cls, __PCEX__, nil); -- [LINE 111]
  local pcex = {}; -- [LINE 113]
  local k, v;
  for k, v in pairs(cls) do -- [LINE 114]
    local idx = builtin_methods_rev[k]; -- [LINE 115]
    if idx ~= nil then -- [LINE 116]
      pcex[idx] = v; -- [LINE 117]
    end;
  end;
  rawset(cls, __PCEX__, pcex); -- [LINE 119]
  register_pyobj(cls); -- [LINE 120]
  return cls; -- [LINE 122]
end;
local function setup_basic_class(cls)
  setup_base_class(cls); -- [LINE 125]
  setmetatable(cls, type); -- [LINE 126]
  return cls; -- [LINE 128]
end;
local function register_builtins_class(cls, ...)
  local bases = {...};
  local mro = {}; -- [LINE 131]
  local idx = 1; -- [LINE 132]
  for i = #bases, 1, -1 do --; -- [LINE 133]
  if true then -- [LINE 134]
    local base = bases[i]; -- [LINE 135]
    mro[idx] = base; -- [LINE 136]
    idx = (idx + 1); -- [LINE 137]
  end;
  end; -- [LINE 138]
  mro[idx] = cls; -- [LINE 140]
  rawset(cls, '__module__', str('builtins')); -- [LINE 141]
  rawset(cls, '__mro__', tuple(mro)); -- [LINE 142]
  IsBuiltinTypes[cls] = true; -- [LINE 143]
  return cls; -- [LINE 144]
end;
local function Fail_OP(a, ax)
  error(lua.concat(to_luaobj(repr(a)), ' are not support ', methods[ax])); -- [LINE 147]
end;
local function Fail_OP_Raw(a, raw_ax)
  error(lua.concat(to_luaobj(repr(a)), ' are not support ', raw_ax)); -- [LINE 150]
end;
local function Fail_OP_Math_Raw(a, b, raw_ax)
  error(lua.concat('Not support ', to_luaobj(repr(a)), ' ', raw_ax, ' ', to_luaobj(repr(b)))); -- [LINE 153]
end;
local function Fail_OP_Math(a, b, ax, extra)
  if extra == nil then -- [LINE 156]
    extra = ''; -- [LINE 157]
  else
    extra = lua.concat(' ', extra); -- [LINE 159]
  end;
  error(lua.concat('Not support ', to_luaobj(repr(a)), ' ', methods[ax], ' ', to_luaobj(repr(b)), extra)); -- [LINE 161]
end;
local function Fail_OP_Math_Pow(a, b, ax, c)
  local extra = ''; -- [LINE 164]
  if c then -- [LINE 165]
    extra = lua.concat('% ', to_luaobj(repr(c))); -- [LINE 166]
  end;
  Fail_OP_Math(a, b, ax, c); -- [LINE 168]
end;
function repr(obj)
  if is_pyobj(obj) then -- [LINE 172]
    return _OP__Repr__(obj); -- [LINE 173]
  else
    return lua.concat('@(', tostring(obj), ')'); -- [LINE 175]
  end;
end;
function print(...)
  local args = {...};
  local write = lua.io.write; -- [LINE 179]
  local sep = ' '; -- [LINE 180]
  local _, arg;
  for _, arg in pairs(args) do -- [LINE 182]
    if is_pyobj(arg) then -- [LINE 183]
      arg = str(arg); -- [LINE 184]
    else
      arg = repr(arg); -- [LINE 186]
    end;
    arg = to_luaobj(arg); -- [LINE 188]
    write(arg); -- [LINE 189]
    write(sep); -- [LINE 190]
  end;
  write('\n'); -- [LINE 192]
end;
function isinstance(cls, targets)
  require_pyobj(obj); -- [LINE 196]
  if type(cls) ~= type then -- [LINE 198]
    cls = type(obj); -- [LINE 199]
  end;
  local mro = cls.mro(); -- [LINE 201]
  assert(type(mro) == tuple); -- [LINE 202]
  local _, supercls;
  for _, supercls in pairs(mro.value) do -- [LINE 204]
    require_pyobj(supercls); -- [LINE 205]
    if supercls == targets then -- [LINE 206]
      return True; -- [LINE 207]
    end;
  end;
  return False; -- [LINE 209]
end;
local function issubclass(cls, targets)
  require_pyobj(obj); -- [LINE 212]
  if type(cls) ~= type then -- [LINE 214]
    error('issubclass() arg 1 must be a class'); -- [LINE 215]
  end;
  local mro = cls.mro(); -- [LINE 217]
  assert(type(mro) == tuple); -- [LINE 218]
  local _, supercls;
  for _, supercls in pairs(ObjValue[mro]) do -- [LINE 220]
    require_pyobj(supercls); -- [LINE 221]
    if supercls == targets then -- [LINE 222]
      return True; -- [LINE 223]
    end;
  end;
  return False; -- [LINE 225]
end;
function id(obj)
  if is_pyobj(obj) then -- [LINE 229]
    return int(ObjID[obj]); -- [LINE 230]
  end;
  Fail_OP_Raw(obj, '__id__!'); -- [LINE 232]
end;
local function OP_Call(ax)
  local function func(a, ...)
    local args = {...};
    assert(require_pyobj(a)); -- [LINE 236]
    local f = rawget(getmetatable(a), __PCEX__)[ax]; -- [LINE 237]
    if f then -- [LINE 238]
      return f(a, ...); -- [LINE 239]
    end;
    Fail_OP(a, ax); -- [LINE 241]
  end;
  return func; -- [LINE 242]
end;
local function OP_Math2(ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 246]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 247]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 248]
    local f = am[ax]; -- [LINE 250]
    if f then -- [LINE 251]
      local ret = f(a, b); -- [LINE 252]
      if ret ~= NotImplemented then -- [LINE 253]
        return ret; -- [LINE 253]
      end;
    end;
    f = bm[bx]; -- [LINE 255]
    if f then -- [LINE 256]
      ret = f(b, a); -- [LINE 257]
      if ret ~= NotImplemented then -- [LINE 258]
        return ret; -- [LINE 258]
      end;
    end;
    Fail_OP_Math(a, b, ax); -- [LINE 260]
  end;
  return func; -- [LINE 262]
end;
local function OP_Math3(cx, ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 266]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 267]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 268]
    local f = am[cx]; -- [LINE 270]
    if f then -- [LINE 271]
      local ret = f(a, b); -- [LINE 272]
      if ret ~= NotImplemented then -- [LINE 273]
        return ret; -- [LINE 273]
      end;
    end;
    f = am[ax]; -- [LINE 276]
    if f then -- [LINE 277]
      ret = f(a, b); -- [LINE 278]
      if ret ~= NotImplemented then -- [LINE 279]
        return ret; -- [LINE 279]
      end;
    end;
    f = bm[bx]; -- [LINE 281]
    if f then -- [LINE 282]
      ret = f(b, a); -- [LINE 283]
      if ret ~= NotImplemented then -- [LINE 284]
        return ret; -- [LINE 284]
      end;
    end;
    Fail_OP_Math(a, b, cx); -- [LINE 286]
  end;
  return func; -- [LINE 288]
end;
local function OP_Math2_Pow(ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 292]
    assert(require_pyobj(c) or c == nil); -- [LINE 293]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 294]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 295]
    local f = am[ax]; -- [LINE 297]
    if f then -- [LINE 298]
      local ret = f(a, b, c); -- [LINE 299]
      if ret ~= NotImplemented then -- [LINE 300]
        return ret; -- [LINE 300]
      end;
    end;
    if c ~= nil then -- [LINE 302]
      f = bm[bx]; -- [LINE 307]
      if f then -- [LINE 308]
        ret = f(b, a); -- [LINE 309]
        if ret ~= NotImplemented then -- [LINE 310]
          return ret; -- [LINE 310]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 312]
  end;
  return func; -- [LINE 314]
end;
local function OP_Math3_Pow(cx, ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 318]
    assert(require_pyobj(c) or c == nil); -- [LINE 319]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 320]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 321]
    local f = am[cx]; -- [LINE 323]
    if f then -- [LINE 324]
      local ret = f(a, b, c); -- [LINE 325]
      if ret ~= NotImplemented then -- [LINE 326]
        return ret; -- [LINE 326]
      end;
    end;
    f = am[ax]; -- [LINE 328]
    if f then -- [LINE 329]
      ret = f(a, b, c); -- [LINE 330]
      if ret ~= NotImplemented then -- [LINE 331]
        return ret; -- [LINE 331]
      end;
    end;
    if c ~= nil then -- [LINE 333]
      f = bm[bx]; -- [LINE 334]
      if f then -- [LINE 335]
        ret = f(b, a); -- [LINE 336]
        if ret ~= NotImplemented then -- [LINE 337]
          return ret; -- [LINE 337]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 339]
  end;
  return func; -- [LINE 341]
end;
function _OP__Is__(a, b)
  require_pyobj(a, b); -- [LINE 345]
  return ObjID[a] == ObjID[b]; -- [LINE 346]
end;
function _OP__IsNot__(a, b)
  return not _OP__Is__(a, b); -- [LINE 349]
end;
local function _(name)
  return builtin_methods_rev[name]; -- [LINE 351]
end;
 -- [LINE 352]
_OP__New__ = OP_Call(_('__new__')); -- [LINE 354]
_OP__Init__ = OP_Call(_('__init__')); -- [LINE 355]
_OP__Del__ = OP_Call(_('__del__')); -- [LINE 356]
_OP__Repr__ = OP_Call(_('__repr__')); -- [LINE 357]
_OP__Str__ = OP_Call(_('__str__')); -- [LINE 358]
_OP__Bytes__ = OP_Call(_('__bytes__')); -- [LINE 359]
_OP__Format__ = OP_Call(_('__format__')); -- [LINE 360]
_OP__Lt__ = OP_Call(_('__lt__')); -- [LINE 361]
_OP__Le__ = OP_Call(_('__le__')); -- [LINE 362]
_OP__Eq__ = OP_Call(_('__eq__')); -- [LINE 363]
_OP__Ne__ = OP_Call(_('__ne__')); -- [LINE 364]
_OP__Gt__ = OP_Call(_('__gt__')); -- [LINE 365]
_OP__Ge__ = OP_Call(_('__ge__')); -- [LINE 366]
_OP__Hash__ = OP_Call(_('__hash__')); -- [LINE 367]
_OP__Bool__ = OP_Call(_('__bool__')); -- [LINE 368]
_OP__Getattr__ = OP_Call(_('__getattr__')); -- [LINE 369]
_OP__Getattribute__ = OP_Call(_('__getattribute__')); -- [LINE 370]
_OP__Setattr__ = OP_Call(_('__setattr__')); -- [LINE 371]
_OP__Delattr__ = OP_Call(_('__delattr__')); -- [LINE 372]
_OP__Dir__ = OP_Call(_('__dir__')); -- [LINE 373]
_OP__Get__ = OP_Call(_('__get__')); -- [LINE 374]
_OP__Set__ = OP_Call(_('__set__')); -- [LINE 375]
_OP__Delete__ = OP_Call(_('__delete__')); -- [LINE 376]
_OP__Slots__ = OP_Call(_('__slots__')); -- [LINE 377]
_OP__Call__ = OP_Call(_('__call__')); -- [LINE 378]
_OP__Len__ = OP_Call(_('__len__')); -- [LINE 379]
_OP__Getitem__ = OP_Call(_('__getitem__')); -- [LINE 380]
_OP__Setitem__ = OP_Call(_('__setitem__')); -- [LINE 381]
_OP__Delitem__ = OP_Call(_('__delitem__')); -- [LINE 382]
_OP__Iter__ = OP_Call(_('__iter__')); -- [LINE 383]
_OP__Reversed__ = OP_Call(_('__reversed__')); -- [LINE 384]
_OP__Contains__ = OP_Call(_('__contains__')); -- [LINE 385]
_OP__Add__ = OP_Math2(_('__add__'), _('__radd__')); -- [LINE 388]
_OP__Sub__ = OP_Math2(_('__sub__'), _('__rsub__')); -- [LINE 389]
_OP__Mul__ = OP_Math2(_('__mul__'), _('__rmul__')); -- [LINE 390]
_OP__Truediv__ = OP_Math2(_('__truediv__'), _('__rtruediv__')); -- [LINE 391]
_OP__Floordiv__ = OP_Math2(_('__floordiv__'), _('__rfloordiv__')); -- [LINE 392]
_OP__Mod__ = OP_Math2(_('__mod__'), _('__rmod__')); -- [LINE 393]
_OP__Divmod__ = OP_Math2(_('__divmod__'), _('__rdivmod__')); -- [LINE 394]
_OP__Pow__ = OP_Math2_Pow(_('__pow__'), _('__rpow__')); -- [LINE 395]
_OP__Lshift__ = OP_Math2(_('__lshift__'), _('__rlshift__')); -- [LINE 396]
_OP__Rshift__ = OP_Math2(_('__rshift__'), _('__rrshift__')); -- [LINE 397]
_OP__And__ = OP_Math2(_('__and__'), _('__rand__')); -- [LINE 398]
_OP__Xor__ = OP_Math2(_('__xor__'), _('__rxor__')); -- [LINE 399]
_OP__Or__ = OP_Math2(_('__or__'), _('__ror__')); -- [LINE 400]
_OP__Iadd__ = OP_Math3(_('__iadd__'), _('__add__'), _('__radd__')); -- [LINE 403]
_OP__Isub__ = OP_Math3(_('__isub__'), _('__sub__'), _('__rsub__')); -- [LINE 404]
_OP__Imul__ = OP_Math3(_('__imul__'), _('__mul__'), _('__rmul__')); -- [LINE 405]
_OP__Itruediv__ = OP_Math3(_('__itruediv__'), _('__truediv__'), _('__rtruediv__')); -- [LINE 406]
_OP__Ifloordiv__ = OP_Math3(_('__ifloordiv__'), _('__floordiv__'), _('__rfloordiv__')); -- [LINE 407]
_OP__Imod__ = OP_Math3(_('__imod__'), _('__mod__'), _('__rmod__')); -- [LINE 408]
_OP__Ipow__ = OP_Math3_Pow(_('__ipow__'), _('__pow__'), _('__rpow__')); -- [LINE 409]
_OP__Ilshift__ = OP_Math3(_('__ilshift__'), _('__lshift__'), _('__rlshift__')); -- [LINE 410]
_OP__Irshift__ = OP_Math3(_('__irshift__'), _('__rshift__'), _('__rrshift__')); -- [LINE 411]
_OP__Iand__ = OP_Math3(_('__iand__'), _('__and__'), _('__rand__')); -- [LINE 412]
_OP__Ixor__ = OP_Math3(_('__ixor__'), _('__xor__'), _('__rxor__')); -- [LINE 413]
_OP__Ior__ = OP_Math3(_('__ior__'), _('__or__'), _('__ror__')); -- [LINE 414]
_OP__Neg__ = OP_Call(_('__neg__')); -- [LINE 417]
_OP__Pos__ = OP_Call(_('__pos__')); -- [LINE 418]
_OP__Abs__ = OP_Call(_('__abs__')); -- [LINE 419]
_OP__Invert__ = OP_Call(_('__invert__')); -- [LINE 420]
_OP__Complex__ = OP_Call(_('__complex__')); -- [LINE 421]
_OP__Int__ = OP_Call(_('__int__')); -- [LINE 422]
_OP__Float__ = OP_Call(_('__float__')); -- [LINE 423]
_OP__Round__ = OP_Call(_('__round__')); -- [LINE 424]
_OP__Index__ = OP_Call(_('__index__')); -- [LINE 425]
_OP__Enter__ = OP_Call(_('__enter__')); -- [LINE 426]
_OP__Exit__ = OP_Call(_('__exit__')); -- [LINE 427]
_OP__Lua__ = OP_Call(_('__lua__')); -- [LINE 430]
 -- [LINE 431]
_ = nil; -- [LINE 432]
object = (function(_G) -- (class object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  __name__ = 'object';
  function __init__(self)
  end;
  setfenv(__init__, _G);
  function __call(self, ...)
    local args = {...};
    return _OP__Call__(self, ...); -- [LINE 441]
  end;
  setfenv(__call, _G);
  function __index(self, key)
    return _OP__Getattribute__(self, key); -- [LINE 444]
  end;
  setfenv(__index, _G);
  function __newindex(self, key, value)
    return _OP__Setattr__(self, key, value); -- [LINE 447]
  end;
  setfenv(__newindex, _G);
  function __tostring(self)
    return lua.concat('#(', to_luaobj(repr(self)), ')'); -- [LINE 450]
  end;
  setfenv(__tostring, _G);
  function __new__(cls, ...)
    local args = {...};
    local instance = register_pyobj({}); -- [LINE 453]
    lua.setmetatable(instance, cls); -- [LINE 454]
    _OP__Init__(instance, ...); -- [LINE 455]
    return instance; -- [LINE 457]
  end;
  setfenv(__new__, _G);
  function __getattribute__(self, k)
    local v = rawget(self, k); -- [LINE 460]
    if v ~= nil then -- [LINE 461]
      return v; -- [LINE 462]
    end;
    local mt = getmetatable(self); -- [LINE 464]
    v = rawget(mt, k); -- [LINE 465]
    if v ~= nil then -- [LINE 466]
      if lua.type(v) == 'function' then -- [LINE 467]
        return (function(...) return v(self, unpack({...})) end); -- [LINE 468]
      else
        return v; -- [LINE 470]
      end;
    end;
    error(lua.concat("Not found '", k, "' attribute.")); -- [LINE 472]
  end;
  setfenv(__getattribute__, _G);
  function __setattr__(self, key, value)
    if IsBuiltinTypes[type(self)] and inited then -- [LINE 475]
      error("TypeError: can't set attributes of built-in/extension type 'object'"); -- [LINE 476]
    end;
    rawset(self, key, value); -- [LINE 479]
  end;
  setfenv(__setattr__, _G);
  function __str__(self)
    return _OP__Repr__(self); -- [LINE 482]
  end;
  setfenv(__str__, _G);
  function __repr__(self)
    local mtable = getmetatable(self); -- [LINE 485]
    return str(concat('<object ', mtable.__name__, ' at ', tostring(self.__id), '>')); -- [LINE 486]
  end;
  setfenv(__repr__, _G);
  return getfenv();
end)(getfenv());
object = setup_base_class(object);
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
    local instance = cls.__new__(cls, ...); -- [LINE 492]
    register_pyobj(instance); -- [LINE 493]
    return instance; -- [LINE 495]
  end;
  setfenv(__call__, _G);
  function __repr__(cls)
    return str(lua.concat("<class '", cls.__name__, "'>")); -- [LINE 498]
  end;
  setfenv(__repr__, _G);
  function mro(cls)
    return cls.__mro__; -- [LINE 501]
  end;
  setfenv(mro, _G);
  return getfenv();
end)(getfenv());
type = setup_base_class(type);
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
    if lua.len(args) == 1 then -- [LINE 506]
      require_pyobj(args[1]); -- [LINE 507]
      return getmetatable(args[1]); -- [LINE 508]
    elseif lua.len(args) == 3 then -- [LINE 509]
    else
      error('Unexcepted arguments.'); -- [LINE 512]
    end;
  end;
  setfenv(__call__, _G);
  return getfenv();
end)(getfenv());
ptype = setup_base_class(ptype);
setmetatable(object, type); -- [LINE 514]
setmetatable(type, ptype); -- [LINE 515]
setmetatable(ptype, ptype); -- [LINE 516]
local BaseException = (function(_G) -- (class BaseException:object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'BaseException';
  function __new__(cls, ...)
    local args = {...};
    local instance = object.__new__(cls); -- [LINE 521]
    instance.args = args; -- [LINE 522]
    _OP__Init__(instance, ...); -- [LINE 523]
  end;
  setfenv(__new__, _G);
  function __repr__(self)
  end;
  setfenv(__repr__, _G);
  return getfenv();
end)(getfenv());
BaseException = setup_basic_class(BaseException);
local BuiltinConstType = (function(_G) -- (class BuiltinConstType:object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'BuiltinConstType';
  function __new__(cls, ...)
    local args = {...};
    if not inited then -- [LINE 531]
      local instance = object.__new__(cls, ...); -- [LINE 532]
      _OP__Init__(instance, ...); -- [LINE 533]
      return instance; -- [LINE 534]
    end;
    return cls._get_singleton(); -- [LINE 536]
  end;
  setfenv(__new__, _G);
  function _get_singleton(cls)
    error('Not defined.'); -- [LINE 539]
  end;
  setfenv(_get_singleton, _G);
  return getfenv();
end)(getfenv());
BuiltinConstType = setup_basic_class(BuiltinConstType);
local NotImplementedType = (function(_G) -- (class NotImplementedType:BuiltinConstType)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({BuiltinConstType}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'NotImplementedType';
  function _get_singleton(cls)
    return NotImplemented; -- [LINE 544]
  end;
  setfenv(_get_singleton, _G);
  function __repr__(self)
    return str('NotImplemented'); -- [LINE 547]
  end;
  setfenv(__repr__, _G);
  return getfenv();
end)(getfenv());
NotImplementedType = setup_basic_class(NotImplementedType);
local EllipsisType = (function(_G) -- (class EllipsisType:BuiltinConstType)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({BuiltinConstType}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'EllipsisType';
  function _get_singleton(self)
    return Ellipsis; -- [LINE 552]
  end;
  setfenv(_get_singleton, _G);
  function __repr__(self)
    return str('Ellipsis'); -- [LINE 555]
  end;
  setfenv(__repr__, _G);
  return getfenv();
end)(getfenv());
EllipsisType = setup_basic_class(EllipsisType);
local NoneType = (function(_G) -- (class NoneType:BuiltinConstType)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({BuiltinConstType}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'NoneType';
  function _get_singleton(cls)
    return None; -- [LINE 560]
  end;
  setfenv(_get_singleton, _G);
  function __repr__(self)
    return str('None'); -- [LINE 563]
  end;
  setfenv(__repr__, _G);
  return getfenv();
end)(getfenv());
NoneType = setup_basic_class(NoneType);
local LuaObject = (function(_G) -- (class LuaObject:object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'LuaObject';
  LuaObject = true; -- [LINE 568]
  function __init__(self, obj)
    local mtable = getmetatable(obj); -- [LINE 572]
    if mtable and rawget(mtable, 'LuaObject') then -- [LINE 573]
      obj = to_luaobj(obj); -- [LINE 574]
    end;
    ObjValue[self] = obj; -- [LINE 576]
  end;
  setfenv(__init__, _G);
  function __str__(self)
    return str(_OP__Repr__(self)); -- [LINE 579]
  end;
  setfenv(__str__, _G);
  function __repr__(self)
    return str(tostring(ObjValue[self])); -- [LINE 582]
  end;
  setfenv(__repr__, _G);
  function __lua__(self)
    return ObjValue[self]; -- [LINE 585]
  end;
  setfenv(__lua__, _G);
  return getfenv();
end)(getfenv());
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
    if is_pyobj(value) then -- [LINE 590]
      self.check_type(value); -- [LINE 591]
    end;
    ObjValue[self] = value; -- [LINE 593]
  end;
  setfenv(__init__, _G);
  function check_type(self, value)
    if type(value) == 'table' then -- [LINE 596]
    elseif value[lua.len(value)] == nil then -- [LINE 597]
    elseif value[1] == nil then -- [LINE 598]
    elseif value[0] ~= nil then -- [LINE 599]
    else
      return true; -- [LINE 601]
    end;
    return false; -- [LINE 603]
  end;
  setfenv(check_type, _G);
  function make_repr(self, s, e)
    local ret = {}; -- [LINE 606]
    local idx = 1; -- [LINE 607]
    local sep = ''; -- [LINE 609]
    ret[idx] = s; -- [LINE 610]
    idx = (idx + 1); -- [LINE 610]
    local k, v;
    for k, v in pairs(ObjValue[self]) do -- [LINE 611]
      ret[idx] = sep; -- [LINE 612]
      idx = (idx + 1); -- [LINE 612]
      ret[idx] = to_luaobj(repr(v)); -- [LINE 613]
      idx = (idx + 1); -- [LINE 613]
      sep = ', '; -- [LINE 614]
    end;
    ret[idx] = e; -- [LINE 616]
    idx = (idx + 1); -- [LINE 616]
    return table.concat(ret); -- [LINE 618]
  end;
  setfenv(make_repr, _G);
  return getfenv();
end)(getfenv());
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
    return self.make_repr('[', ']'); -- [LINE 624]
  end;
  setfenv(__repr__, _G);
  function __setattr__(self, key, value)
    error('Not allowed'); -- [LINE 627]
  end;
  setfenv(__setattr__, _G);
  return getfenv();
end)(getfenv());
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
    return self.make_repr('(', ')'); -- [LINE 633]
  end;
  setfenv(__repr__, _G);
  function __setattr__(self, key, value)
    error('Not allowed'); -- [LINE 636]
  end;
  setfenv(__setattr__, _G);
  return getfenv();
end)(getfenv());
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
    if is_pyobj(value) then -- [LINE 642]
      value = _OP__Str__(value); -- [LINE 643]
      value = to_luaobj(value); -- [LINE 644]
    end;
    ObjValue[self] = value; -- [LINE 646]
  end;
  setfenv(__init__, _G);
  function __str__(self)
    return self; -- [LINE 649]
  end;
  setfenv(__str__, _G);
  function __repr__(self)
    return str(lua.concat("'", ObjValue[self], "'")); -- [LINE 652]
  end;
  setfenv(__repr__, _G);
  return getfenv();
end)(getfenv());
str = setup_basic_class(str);
local function make_bool(value)
  local instance = {['value'] = value}; -- [LINE 655]
  register_pyobj(instance); -- [LINE 656]
  setmetatable(instance, bool); -- [LINE 657]
  return instance; -- [LINE 659]
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
    if not inited then -- [LINE 665]
      local instance = object.__new__(cls); -- [LINE 666]
      ObjValue[instance] = value; -- [LINE 667]
      return instance; -- [LINE 668]
    end;
    if is_pyobj(value) then -- [LINE 670]
      value = _OP__Bool__(value); -- [LINE 671]
    else
      value = value and true or false; -- [LINE 674]
    end;
    if value == true then -- [LINE 676]
      return True; -- [LINE 677]
    elseif value == false then -- [LINE 678]
      return False; -- [LINE 679]
    elseif is_pyobj(value) and type(value) == bool then -- [LINE 680]
      return value; -- [LINE 681]
    end;
    error('__Bool__ are returned unknown value.'); -- [LINE 683]
  end;
  setfenv(__new__, _G);
  function __repr__(self)
    local value = ObjValue[self]; -- [LINE 686]
    if value == true then -- [LINE 687]
      return str('True'); -- [LINE 688]
    elseif value == false then -- [LINE 689]
      return str('False'); -- [LINE 690]
    end;
  end;
  setfenv(__repr__, _G);
  return getfenv();
end)(getfenv());
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
    return int((ObjValue[self] + ObjValue[other])); -- [LINE 698]
  end;
  setfenv(__add__, _G);
  return getfenv();
end)(getfenv());
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
dict = setup_basic_class(dict);
local function inital()
  register_builtins_class(object); -- [LINE 707]
  register_builtins_class(NotImplementedType, object); -- [LINE 708]
  register_builtins_class(EllipsisType, object); -- [LINE 709]
  register_builtins_class(NoneType, object); -- [LINE 710]
  register_builtins_class(type, object); -- [LINE 711]
  register_builtins_class(list, object); -- [LINE 712]
  register_builtins_class(tuple, object); -- [LINE 713]
  register_builtins_class(str, object); -- [LINE 714]
  register_builtins_class(int, object); -- [LINE 715]
  register_builtins_class(dict, object); -- [LINE 716]
  _M['NotImplemented'] = NotImplementedType(); -- [LINE 717]
  _M['Ellipsis'] = EllipsisType(); -- [LINE 718]
  _M['None'] = NoneType(); -- [LINE 719]
  _M['True'] = bool(true); -- [LINE 720]
  _M['False'] = bool(false); -- [LINE 721]
  return true; -- [LINE 723]
end;
inited = inital(); -- [LINE 725]
local function table_len(x)
  local count = 0; -- [LINE 731]
  local k, v;
  for k, v in pairs(x) do -- [LINE 732]
    count = (count + 1); -- [LINE 732]
  end;
  return count; -- [LINE 733]
end;
local x = list({int(1), int(2), int(3)}); -- [LINE 735]
local y = int(5); -- [LINE 736]
local z = int(7); -- [LINE 737]
print(x); -- [LINE 739]
print(True == nil); -- [LINE 740]
print(True); -- [LINE 741]
print(issubclass(int, object)); -- [LINE 742]
print(int.mro()); -- [LINE 743]
print(_OP__Add__(y, z)); -- [LINE 744]
