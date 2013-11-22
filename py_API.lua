local _M = getfenv();
if pyscripter then -- [LINE 1]
  exit(__import__('pc').main()); -- [LINE 1]
end;
 -- [LINE 3]
lua = {}; -- [LINE 6]
lua.len = (function(obj) return #obj; end); -- [LINE 7]
lua.concat = (function(...) return table.concat({...}); end); -- [LINE 8]
local key, value;
for key, value in pairs(_G) do -- [LINE 9]
  lua[key] = value; -- [LINE 10]
end;
local PY_OBJ_TAG = '#'; -- [LINE 12]
local LUA_OBJ_TAG = '@'; -- [LINE 13]
local TAG = '[PY]'; -- [LINE 15]
local ObjLastID = 0; -- [LINE 16]
local inited = False; -- [LINE 17]
local __PCEX__ = '__PCEX__'; -- [LINE 19]
local builtins = 'builtins'; -- [LINE 20]
local ObjID = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 23]
local ObjValue = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 24]
local Obj_FromID = setmetatable({}, {['__mode'] = 'v'}); -- [LINE 25]
local IsBuiltinTypes = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 26]
local builtin_methods = {'__new__', '__init__', '__del__', '__repr__', '__str__', '__bytes__', '__format__', '__lt__', '__le__', '__eq__', '__ne__', '__gt__', '__ge__', '__hash__', '__bool__', '__getattr__', '__getattribute__', '__setattr__', '__delattr__', '__dir__', '__get__', '__set__', '__delete__', '__slots__', '__call__', '__len__', '__getitem__', '__setitem__', '__delitem__', '__iter__', '__reversed__', '__contains__', '__add__', '__sub__', '__mul__', '__truediv__', '__floordiv__', '__mod__', '__divmod__', '__pow__', '__lshift__', '__rshift__', '__and__', '__xor__', '__or__', '__radd__', '__rsub__', '__rmul__', '__rtruediv__', '__rfloordiv__', '__rmod__', '__rdivmod__', '__rpow__', '__rlshift__', '__rrshift__', '__rand__', '__rxor__', '__ror__', '__iadd__', '__isub__', '__imul__', '__itruediv__', '__ifloordiv__', '__imod__', '__ipow__', '__ilshift__', '__irshift__', '__iand__', '__ixor__', '__ior__', '__neg__', '__pos__', '__abs__', '__invert__', '__complex__', '__int__', '__float__', '__round__', '__index__', '__enter__', '__exit__', '__lua__'}; -- [LINE 29]
local builtin_methods_rev = {}; -- [LINE 30]
local k, v;
for k, v in pairs(builtin_methods) do -- [LINE 31]
  builtin_methods_rev[v] = k; -- [LINE 32]
end;
assert(builtin_methods[42] == '__rshift__'); -- [LINE 34]
assert(builtin_methods_rev['__pos__'] == 72); -- [LINE 35]
local error = nil; -- [LINE 36]
local function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 39]
    error('This is not number', 2); -- [LINE 40]
  end;
  return math.floor(num) ~= num; -- [LINE 42]
end;
local function is_pyobj(obj)
  return ObjID[obj] ~= nil; -- [LINE 45]
end;
local function PObj(obj)
  if is_pyobj(obj) then -- [LINE 48]
    return obj; -- [LINE 49]
  else
    return LuaObject(obj); -- [LINE 51]
  end;
end;
local function LObj(obj)
  if is_pyobj(obj) then -- [LINE 54]
    return _OP__Lua__(obj); -- [LINE 55]
  else
    return obj; -- [LINE 57]
  end;
end;
local function require_pyobj(...)
  local objs = {...};
  local idx, obj;
  for idx, obj in pairs(objs) do -- [LINE 60]
    if not is_pyobj(obj) then -- [LINE 61]
      lua.print(lua.type(obj), obj); -- [LINE 62]
      error('Require python object.'); -- [LINE 63]
    end;
  end;
  return true; -- [LINE 65]
end;
local function register_pyobj(obj)
  ObjLastID = (ObjLastID + 1); -- [LINE 69]
  local obj_id = ObjLastID; -- [LINE 70]
  ObjID[obj] = obj_id; -- [LINE 72]
  Obj_FromID[obj_id] = obj; -- [LINE 73]
  return obj; -- [LINE 74]
end;
function error(msg, level)
  if level == nil then -- [LINE 77]
    level = 1; -- [LINE 78]
  end;
  if is_pyobj(msg) then -- [LINE 80]
    msg = LObj(msg); -- [LINE 81]
  end;
  level = (level + 1); -- [LINE 83]
  lua.error(lua.concat(TAG, ' ', tostring(msg)), level); -- [LINE 84]
end;
local function require_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 87]
    if value == nil then -- [LINE 88]
      error('SystemError: Not Enough Item'); -- [LINE 89]
    end;
  end;
  return True; -- [LINE 91]
end;
local function nonrequire_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 94]
    if value ~= nil then -- [LINE 95]
      error('SystemError: Not Enough Item'); -- [LINE 96]
    end;
  end;
  return True; -- [LINE 98]
end;
function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 101]
    error('This is not number', 2); -- [LINE 102]
  end;
  return math.floor(num) ~= num; -- [LINE 104]
end;
local function setup_base_class(cls)
  rawset(cls, __PCEX__, nil); -- [LINE 107]
  local pcex = {}; -- [LINE 109]
  local k, v;
  for k, v in pairs(cls) do -- [LINE 110]
    local idx = builtin_methods_rev[k]; -- [LINE 111]
    if idx ~= nil then -- [LINE 112]
      pcex[idx] = v; -- [LINE 113]
    end;
  end;
  rawset(cls, __PCEX__, pcex); -- [LINE 115]
  IsBuiltinTypes[cls] = false; -- [LINE 116]
  register_pyobj(cls); -- [LINE 117]
  return cls; -- [LINE 119]
end;
local function setup_basic_class(cls)
  setup_base_class(cls); -- [LINE 122]
  setmetatable(cls, type); -- [LINE 123]
  return cls; -- [LINE 125]
end;
local function setup_hide_class(cls)
  IsBuiltinTypes[cls] = nil; -- [LINE 128]
  return cls; -- [LINE 129]
end;
local function register_builtins_class(cls)
  local idx = 1; -- [LINE 132]
  local mro = {}; -- [LINE 133]
  local bases = rawget(cls, '__bases__'); -- [LINE 135]
  if bases ~= nil then -- [LINE 136]
    for i = #bases, 1, -1 do --; -- [LINE 137]
    if true then -- [LINE 138]
      local base = bases[i]; -- [LINE 139]
      if IsBuiltinTypes[base] ~= nil then -- [LINE 140]
        mro[idx] = base; -- [LINE 141]
        idx = (idx + 1); -- [LINE 142]
      end;
    end;
    end; -- [LINE 143]
  end;
  mro[idx] = cls; -- [LINE 145]
  idx = (idx + 1); -- [LINE 146]
  if cls ~= object then -- [LINE 148]
    mro[idx] = object; -- [LINE 149]
    idx = (idx + 1); -- [LINE 150]
  end;
  rawset(cls, '__bases__', nil); -- [LINE 152]
  rawset(cls, '__name__', str(rawget(cls, '__name__'))); -- [LINE 153]
  rawset(cls, '__module__', str('builtins')); -- [LINE 154]
  rawset(cls, '__mro__', tuple(mro)); -- [LINE 155]
  IsBuiltinTypes[cls] = true; -- [LINE 157]
  return cls; -- [LINE 158]
end;
local function Fail_OP(a, ax)
  error(lua.concat(LObj(repr(a)), ' are not support ', builtin_methods[ax])); -- [LINE 161]
end;
local function Fail_OP_Raw(a, raw_ax)
  error(lua.concat(LObj(repr(a)), ' are not support ', raw_ax)); -- [LINE 164]
end;
local function Fail_OP_Math_Raw(a, b, raw_ax)
  error(lua.concat('Not support ', LObj(repr(a)), ' ', raw_ax, ' ', LObj(repr(b)))); -- [LINE 167]
end;
local function Fail_OP_Math(a, b, ax, extra)
  if extra == nil then -- [LINE 170]
    extra = ''; -- [LINE 171]
  else
    extra = lua.concat(' ', extra); -- [LINE 173]
  end;
  error(lua.concat('Not support ', LObj(repr(a)), ' ', builtin_methods[ax], ' ', LObj(repr(b)), extra)); -- [LINE 175]
end;
local function Fail_OP_Math_Pow(a, b, ax, c)
  local extra = ''; -- [LINE 178]
  if c then -- [LINE 179]
    extra = lua.concat('% ', LObj(repr(c))); -- [LINE 180]
  end;
  Fail_OP_Math(a, b, ax, c); -- [LINE 182]
end;
local function OP_Call(ax)
  local function func(a, ...)
    local args = {...};
    assert(require_pyobj(a)); -- [LINE 186]
    local f = rawget(getmetatable(a), __PCEX__)[ax]; -- [LINE 187]
    if f then -- [LINE 188]
      return f(a, ...); -- [LINE 189]
    end;
    Fail_OP(a, ax); -- [LINE 191]
  end;
  return func; -- [LINE 192]
end;
local function OP_Math2(ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 196]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 197]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 198]
    local f = am[ax]; -- [LINE 200]
    if f then -- [LINE 201]
      local ret = f(a, b); -- [LINE 202]
      if ret ~= NotImplemented then -- [LINE 203]
        return ret; -- [LINE 203]
      end;
    end;
    f = bm[bx]; -- [LINE 205]
    if f then -- [LINE 206]
      ret = f(b, a); -- [LINE 207]
      if ret ~= NotImplemented then -- [LINE 208]
        return ret; -- [LINE 208]
      end;
    end;
    Fail_OP_Math(a, b, ax); -- [LINE 210]
  end;
  return func; -- [LINE 212]
end;
local function OP_Math3(cx, ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 216]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 217]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 218]
    local is_n = isinstance(a, int) == True or isinstance(b, float) == True; -- [LINE 219]
    if is_n then -- [LINE 221]
      local f = am[ax]; -- [LINE 222]
      if f then -- [LINE 223]
        local ret = f(a, b); -- [LINE 224]
        if ret ~= NotImplemented then -- [LINE 225]
          return ret; -- [LINE 225]
        end;
      end;
    end;
    f = am[cx]; -- [LINE 227]
    if f then -- [LINE 228]
      ret = f(a, b); -- [LINE 229]
      if ret ~= NotImplemented then -- [LINE 230]
        return ret; -- [LINE 230]
      end;
    end;
    if not is_n then -- [LINE 233]
      f = am[ax]; -- [LINE 234]
      if f then -- [LINE 235]
        ret = f(a, b); -- [LINE 236]
        if ret ~= NotImplemented then -- [LINE 237]
          return ret; -- [LINE 237]
        end;
      end;
    end;
    f = bm[bx]; -- [LINE 239]
    if f then -- [LINE 240]
      ret = f(b, a); -- [LINE 241]
      if ret ~= NotImplemented then -- [LINE 242]
        return ret; -- [LINE 242]
      end;
    end;
    Fail_OP_Math(a, b, cx); -- [LINE 244]
  end;
  return func; -- [LINE 246]
end;
local function OP_Math2_Pow(ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 250]
    assert(require_pyobj(c) or c == nil); -- [LINE 251]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 252]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 253]
    local f = am[ax]; -- [LINE 255]
    if f then -- [LINE 256]
      local ret = f(a, b, c); -- [LINE 257]
      if ret ~= NotImplemented then -- [LINE 258]
        return ret; -- [LINE 258]
      end;
    end;
    if c ~= nil then -- [LINE 260]
      f = bm[bx]; -- [LINE 265]
      if f then -- [LINE 266]
        ret = f(b, a); -- [LINE 267]
        if ret ~= NotImplemented then -- [LINE 268]
          return ret; -- [LINE 268]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 270]
  end;
  return func; -- [LINE 272]
end;
local function OP_Math3_Pow(cx, ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 276]
    assert(require_pyobj(c) or c == nil); -- [LINE 277]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 278]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 279]
    local f = am[cx]; -- [LINE 281]
    if f then -- [LINE 282]
      local ret = f(a, b, c); -- [LINE 283]
      if ret ~= NotImplemented then -- [LINE 284]
        return ret; -- [LINE 284]
      end;
    end;
    f = am[ax]; -- [LINE 286]
    if f then -- [LINE 287]
      ret = f(a, b, c); -- [LINE 288]
      if ret ~= NotImplemented then -- [LINE 289]
        return ret; -- [LINE 289]
      end;
    end;
    if c ~= nil then -- [LINE 291]
      f = bm[bx]; -- [LINE 292]
      if f then -- [LINE 293]
        ret = f(b, a); -- [LINE 294]
        if ret ~= NotImplemented then -- [LINE 295]
          return ret; -- [LINE 295]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 297]
  end;
  return func; -- [LINE 299]
end;
function _OP__Is__(a, b)
  require_pyobj(a, b); -- [LINE 303]
  return ObjID[a] == ObjID[b]; -- [LINE 304]
end;
function _OP__IsNot__(a, b)
  return not _OP__Is__(a, b); -- [LINE 307]
end;
local function _(name)
  return builtin_methods_rev[name]; -- [LINE 309]
end;
 -- [LINE 310]
_OP__New__ = OP_Call(_('__new__')); -- [LINE 312]
_OP__Init__ = OP_Call(_('__init__')); -- [LINE 313]
_OP__Del__ = OP_Call(_('__del__')); -- [LINE 314]
_OP__Repr__ = OP_Call(_('__repr__')); -- [LINE 315]
_OP__Str__ = OP_Call(_('__str__')); -- [LINE 316]
_OP__Bytes__ = OP_Call(_('__bytes__')); -- [LINE 317]
_OP__Format__ = OP_Call(_('__format__')); -- [LINE 318]
_OP__Lt__ = OP_Call(_('__lt__')); -- [LINE 319]
_OP__Le__ = OP_Call(_('__le__')); -- [LINE 320]
_OP__Eq__ = OP_Call(_('__eq__')); -- [LINE 321]
_OP__Ne__ = OP_Call(_('__ne__')); -- [LINE 322]
_OP__Gt__ = OP_Call(_('__gt__')); -- [LINE 323]
_OP__Ge__ = OP_Call(_('__ge__')); -- [LINE 324]
_OP__Hash__ = OP_Call(_('__hash__')); -- [LINE 325]
_OP__Bool__ = OP_Call(_('__bool__')); -- [LINE 326]
_OP__Getattr__ = OP_Call(_('__getattr__')); -- [LINE 327]
_OP__Getattribute__ = OP_Call(_('__getattribute__')); -- [LINE 328]
_OP__Setattr__ = OP_Call(_('__setattr__')); -- [LINE 329]
_OP__Delattr__ = OP_Call(_('__delattr__')); -- [LINE 330]
_OP__Dir__ = OP_Call(_('__dir__')); -- [LINE 331]
_OP__Get__ = OP_Call(_('__get__')); -- [LINE 332]
_OP__Set__ = OP_Call(_('__set__')); -- [LINE 333]
_OP__Delete__ = OP_Call(_('__delete__')); -- [LINE 334]
_OP__Slots__ = OP_Call(_('__slots__')); -- [LINE 335]
_OP__Call__ = OP_Call(_('__call__')); -- [LINE 336]
_OP__Len__ = OP_Call(_('__len__')); -- [LINE 337]
_OP__Getitem__ = OP_Call(_('__getitem__')); -- [LINE 338]
_OP__Setitem__ = OP_Call(_('__setitem__')); -- [LINE 339]
_OP__Delitem__ = OP_Call(_('__delitem__')); -- [LINE 340]
_OP__Iter__ = OP_Call(_('__iter__')); -- [LINE 341]
_OP__Reversed__ = OP_Call(_('__reversed__')); -- [LINE 342]
_OP__Contains__ = OP_Call(_('__contains__')); -- [LINE 343]
_OP__Add__ = OP_Math2(_('__add__'), _('__radd__')); -- [LINE 346]
_OP__Sub__ = OP_Math2(_('__sub__'), _('__rsub__')); -- [LINE 347]
_OP__Mul__ = OP_Math2(_('__mul__'), _('__rmul__')); -- [LINE 348]
_OP__Truediv__ = OP_Math2(_('__truediv__'), _('__rtruediv__')); -- [LINE 349]
_OP__Floordiv__ = OP_Math2(_('__floordiv__'), _('__rfloordiv__')); -- [LINE 350]
_OP__Mod__ = OP_Math2(_('__mod__'), _('__rmod__')); -- [LINE 351]
_OP__Divmod__ = OP_Math2(_('__divmod__'), _('__rdivmod__')); -- [LINE 352]
_OP__Pow__ = OP_Math2_Pow(_('__pow__'), _('__rpow__')); -- [LINE 353]
_OP__Lshift__ = OP_Math2(_('__lshift__'), _('__rlshift__')); -- [LINE 354]
_OP__Rshift__ = OP_Math2(_('__rshift__'), _('__rrshift__')); -- [LINE 355]
_OP__And__ = OP_Math2(_('__and__'), _('__rand__')); -- [LINE 356]
_OP__Xor__ = OP_Math2(_('__xor__'), _('__rxor__')); -- [LINE 357]
_OP__Or__ = OP_Math2(_('__or__'), _('__ror__')); -- [LINE 358]
_OP__Iadd__ = OP_Math3(_('__iadd__'), _('__add__'), _('__radd__')); -- [LINE 361]
_OP__Isub__ = OP_Math3(_('__isub__'), _('__sub__'), _('__rsub__')); -- [LINE 362]
_OP__Imul__ = OP_Math3(_('__imul__'), _('__mul__'), _('__rmul__')); -- [LINE 363]
_OP__Itruediv__ = OP_Math3(_('__itruediv__'), _('__truediv__'), _('__rtruediv__')); -- [LINE 364]
_OP__Ifloordiv__ = OP_Math3(_('__ifloordiv__'), _('__floordiv__'), _('__rfloordiv__')); -- [LINE 365]
_OP__Imod__ = OP_Math3(_('__imod__'), _('__mod__'), _('__rmod__')); -- [LINE 366]
_OP__Ipow__ = OP_Math3_Pow(_('__ipow__'), _('__pow__'), _('__rpow__')); -- [LINE 367]
_OP__Ilshift__ = OP_Math3(_('__ilshift__'), _('__lshift__'), _('__rlshift__')); -- [LINE 368]
_OP__Irshift__ = OP_Math3(_('__irshift__'), _('__rshift__'), _('__rrshift__')); -- [LINE 369]
_OP__Iand__ = OP_Math3(_('__iand__'), _('__and__'), _('__rand__')); -- [LINE 370]
_OP__Ixor__ = OP_Math3(_('__ixor__'), _('__xor__'), _('__rxor__')); -- [LINE 371]
_OP__Ior__ = OP_Math3(_('__ior__'), _('__or__'), _('__ror__')); -- [LINE 372]
_OP__Neg__ = OP_Call(_('__neg__')); -- [LINE 375]
_OP__Pos__ = OP_Call(_('__pos__')); -- [LINE 376]
_OP__Abs__ = OP_Call(_('__abs__')); -- [LINE 377]
_OP__Invert__ = OP_Call(_('__invert__')); -- [LINE 378]
_OP__Complex__ = OP_Call(_('__complex__')); -- [LINE 379]
_OP__Int__ = OP_Call(_('__int__')); -- [LINE 380]
_OP__Float__ = OP_Call(_('__float__')); -- [LINE 381]
_OP__Round__ = OP_Call(_('__round__')); -- [LINE 382]
_OP__Index__ = OP_Call(_('__index__')); -- [LINE 383]
_OP__Enter__ = OP_Call(_('__enter__')); -- [LINE 384]
_OP__Exit__ = OP_Call(_('__exit__')); -- [LINE 385]
_OP__Lua__ = OP_Call(_('__lua__')); -- [LINE 388]
function repr(obj)
  if is_pyobj(obj) then -- [LINE 392]
    return _OP__Repr__(obj); -- [LINE 393]
  else
    return lua.concat(LUA_OBJ_TAG, '(', tostring(obj), ')'); -- [LINE 395]
  end;
end;
function print(...)
  local args = {...};
  local write = lua.io.write; -- [LINE 398]
  local sep = ' '; -- [LINE 399]
  local _, arg;
  for _, arg in pairs(args) do -- [LINE 401]
    if is_pyobj(arg) then -- [LINE 402]
      arg = str(arg); -- [LINE 403]
    else
      arg = repr(arg); -- [LINE 405]
    end;
    arg = LObj(arg); -- [LINE 407]
    write(arg); -- [LINE 408]
    write(sep); -- [LINE 409]
  end;
  write('\n'); -- [LINE 411]
end;
function isinstance(obj, targets)
  require_pyobj(obj); -- [LINE 414]
  local cls = type(obj); -- [LINE 416]
  local mro = cls.mro(); -- [LINE 417]
  assert(type(mro) == tuple); -- [LINE 418]
  local _, supercls;
  for _, supercls in pairs(ObjValue[mro]) do -- [LINE 420]
    require_pyobj(supercls); -- [LINE 421]
    if supercls == targets then -- [LINE 422]
      return True; -- [LINE 423]
    end;
  end;
  return False; -- [LINE 425]
end;
function issubclass(cls, targets)
  require_pyobj(obj); -- [LINE 428]
  if type(cls) ~= type then -- [LINE 430]
    error('issubclass() arg 1 must be a class'); -- [LINE 431]
  end;
  local mro = cls.mro(); -- [LINE 433]
  assert(type(mro) == tuple); -- [LINE 434]
  local _, supercls;
  for _, supercls in pairs(ObjValue[mro]) do -- [LINE 436]
    require_pyobj(supercls); -- [LINE 437]
    if supercls == targets then -- [LINE 438]
      return True; -- [LINE 439]
    end;
  end;
  return False; -- [LINE 441]
end;
function id(obj)
  if is_pyobj(obj) then -- [LINE 444]
    return int(ObjID[obj]); -- [LINE 445]
  end;
  Fail_OP_Raw(obj, '__id!'); -- [LINE 447]
end;
function len(obj)
  return _OP__Len__(obj); -- [LINE 450]
end;
 -- [LINE 452]
_ = nil; -- [LINE 453]
object = (function(_G) -- (class object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  __name__ = 'object';
  function __init__(self)
  end;
  setfenv(__init__, _G);
  function __call(self, ...)
    local args = {...};
    return _OP__Call__(self, ...); -- [LINE 463]
  end;
  setfenv(__call, _G);
  function __index(self, key)
    return _OP__Getattribute__(self, key); -- [LINE 466]
  end;
  setfenv(__index, _G);
  function __newindex(self, key, value)
    return _OP__Setattr__(self, key, value); -- [LINE 469]
  end;
  setfenv(__newindex, _G);
  function __tostring(self)
    return lua.concat(PY_OBJ_TAG, '(', LObj(repr(self)), ')'); -- [LINE 472]
  end;
  setfenv(__tostring, _G);
  function __new__(cls, ...)
    local args = {...};
    local instance = {}; -- [LINE 475]
    instance = register_pyobj(instance); -- [LINE 476]
    lua.setmetatable(instance, cls); -- [LINE 477]
    _OP__Init__(instance, ...); -- [LINE 478]
    return instance; -- [LINE 480]
  end;
  setfenv(__new__, _G);
  function __getattribute__(self, k)
    local v = rawget(self, k); -- [LINE 483]
    if v ~= nil then -- [LINE 484]
      return v; -- [LINE 485]
    end;
    local mt = getmetatable(self); -- [LINE 487]
    v = rawget(mt, k); -- [LINE 488]
    if v ~= nil then -- [LINE 489]
      if lua.type(v) == 'function' then -- [LINE 490]
        return (function(...) return v(self, unpack({...})); end); -- [LINE 491]
      else
        return v; -- [LINE 493]
      end;
    end;
    error(lua.concat("Not found '", k, "' attribute.")); -- [LINE 495]
  end;
  setfenv(__getattribute__, _G);
  function __setattr__(self, key, value)
    if IsBuiltinTypes[type(self)] and inited then -- [LINE 498]
      error("TypeError: can't set attributes of built-in/extension type 'object'"); -- [LINE 499]
    end;
    rawset(self, key, value); -- [LINE 502]
  end;
  setfenv(__setattr__, _G);
  function __str__(self)
    return _OP__Repr__(self); -- [LINE 505]
  end;
  setfenv(__str__, _G);
  function __repr__(self)
    local mtable = getmetatable(self); -- [LINE 508]
    return str(lua.concat('<object ', LObj(mtable.__name__), ' at ', LObj(id(self)), '>')); -- [LINE 509]
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
  __bases__ = {object};
  __name__ = 'type';
  function __call__(cls, ...)
    local args = {...};
    local instance = cls.__new__(cls, ...); -- [LINE 515]
    register_pyobj(instance); -- [LINE 516]
    return instance; -- [LINE 518]
  end;
  setfenv(__call__, _G);
  function __repr__(cls)
    return str(lua.concat("<class '", LObj(cls.__name__), "'>")); -- [LINE 521]
  end;
  setfenv(__repr__, _G);
  function mro(cls)
    return cls.__mro__; -- [LINE 524]
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
  __bases__ = {type};
  __name__ = 'ptype';
  function __call__(cls, ...)
    local args = {...};
    if lua.len(args) == 1 then -- [LINE 529]
      require_pyobj(args[1]); -- [LINE 530]
      return getmetatable(args[1]); -- [LINE 531]
    elseif lua.len(args) == 3 then -- [LINE 532]
    else
      error('Unexcepted arguments.'); -- [LINE 535]
    end;
  end;
  setfenv(__call__, _G);
  return getfenv();
end)(getfenv());
ptype = setup_base_class(ptype);
setmetatable(object, type); -- [LINE 537]
setmetatable(type, ptype); -- [LINE 538]
setmetatable(ptype, ptype); -- [LINE 539]
local BaseException = (function(_G) -- (class BaseException:object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __bases__ = {object};
  __name__ = 'BaseException';
  args = nil; -- [LINE 543]
  function __new__(cls, ...)
    local args = {...};
    local param = tuple(args); -- [LINE 546]
    local instance = object.__new__(cls); -- [LINE 547]
    rawset(instance, 'args', param); -- [LINE 548]
    _OP__Init__(instance, param); -- [LINE 549]
    return instance; -- [LINE 550]
  end;
  setfenv(__new__, _G);
  function __str__(self)
    local length = LObj(len(self.args)); -- [LINE 553]
    if length == 0 then -- [LINE 554]
      return str(''); -- [LINE 555]
    elseif length == 1 then -- [LINE 556]
      return str(_OP__Getitem__(self.args, int(0))); -- [LINE 557]
    end;
  end;
  setfenv(__str__, _G);
  function __repr__(self)
    local excname = LObj(type(self).__name__); -- [LINE 560]
    return lua.concat(excname, repr(self.args)); -- [LINE 561]
  end;
  setfenv(__repr__, _G);
  function __lua__(self)
    local excname = LObj(type(self).__name__); -- [LINE 564]
    local value = str(self); -- [LINE 565]
    if LObj(len(value)) > 0 then -- [LINE 567]
      return lua.concat(excname, ': ', LObj(value)); -- [LINE 568]
    else
      return lua.concat(excname); -- [LINE 570]
    end;
  end;
  setfenv(__lua__, _G);
  return getfenv();
end)(getfenv());
BaseException = setup_basic_class(BaseException);
local Exception = (function(_G) -- (class Exception:BaseException)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({BaseException}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __bases__ = {BaseException};
  __name__ = 'Exception';
  return getfenv();
end)(getfenv());
Exception = setup_basic_class(Exception);
local BuiltinConstType = (function(_G) -- (class BuiltinConstType:object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __bases__ = {object};
  __name__ = 'BuiltinConstType';
  function __new__(cls, ...)
    local args = {...};
    if not inited then -- [LINE 579]
      local instance = object.__new__(cls, ...); -- [LINE 580]
      _OP__Init__(instance, ...); -- [LINE 581]
      return instance; -- [LINE 582]
    end;
    return cls._get_singleton(); -- [LINE 584]
  end;
  setfenv(__new__, _G);
  function _get_singleton(cls)
    error('Not defined.'); -- [LINE 587]
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
  __bases__ = {BuiltinConstType};
  __name__ = 'NotImplementedType';
  function _get_singleton(cls)
    return NotImplemented; -- [LINE 592]
  end;
  setfenv(_get_singleton, _G);
  function __repr__(self)
    return str('NotImplemented'); -- [LINE 595]
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
  __bases__ = {BuiltinConstType};
  __name__ = 'EllipsisType';
  function _get_singleton(self)
    return Ellipsis; -- [LINE 600]
  end;
  setfenv(_get_singleton, _G);
  function __repr__(self)
    return str('Ellipsis'); -- [LINE 603]
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
  __bases__ = {BuiltinConstType};
  __name__ = 'NoneType';
  function _get_singleton(cls)
    return None; -- [LINE 608]
  end;
  setfenv(_get_singleton, _G);
  function __repr__(self)
    return str('None'); -- [LINE 611]
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
  __bases__ = {object};
  __name__ = 'LuaObject';
  LuaObject = true; -- [LINE 617]
  function __init__(self, obj)
    local mtable = getmetatable(obj); -- [LINE 621]
    if mtable and rawget(mtable, 'LuaObject') then -- [LINE 622]
      obj = LObj(obj); -- [LINE 623]
    end;
    ObjValue[self] = obj; -- [LINE 625]
  end;
  setfenv(__init__, _G);
  function __str__(self)
    return str(_OP__Repr__(self)); -- [LINE 628]
  end;
  setfenv(__str__, _G);
  function __repr__(self)
    return str(tostring(ObjValue[self])); -- [LINE 631]
  end;
  setfenv(__repr__, _G);
  function __lua__(self)
    return ObjValue[self]; -- [LINE 634]
  end;
  setfenv(__lua__, _G);
  return getfenv();
end)(getfenv());
LuaObject = setup_basic_class(LuaObject);
LuaObject = setup_hide_class(LuaObject);
local LuaValueOnlySequance = (function(_G) -- (class LuaValueOnlySequance:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __bases__ = {LuaObject};
  __name__ = 'LuaValueOnlySequance';
  function __init__(self, value)
    if is_pyobj(value) then -- [LINE 640]
      self.check_type(value); -- [LINE 641]
    end;
    ObjValue[self] = value; -- [LINE 643]
  end;
  setfenv(__init__, _G);
  function check_type(self, value)
    if type(value) == 'table' then -- [LINE 646]
    elseif value[lua.len(value)] == nil then -- [LINE 647]
    elseif value[1] == nil then -- [LINE 648]
    elseif value[0] ~= nil then -- [LINE 649]
    else
      return true; -- [LINE 651]
    end;
    return false; -- [LINE 653]
  end;
  setfenv(check_type, _G);
  function make_repr(self, s, e)
    local ret = {}; -- [LINE 656]
    local idx = 1; -- [LINE 657]
    local sep = ''; -- [LINE 659]
    ret[idx] = s; -- [LINE 660]
    idx = (idx + 1); -- [LINE 660]
    local k, v;
    for k, v in pairs(ObjValue[self]) do -- [LINE 661]
      ret[idx] = sep; -- [LINE 662]
      idx = (idx + 1); -- [LINE 662]
      ret[idx] = LObj(repr(v)); -- [LINE 663]
      idx = (idx + 1); -- [LINE 663]
      sep = ', '; -- [LINE 664]
    end;
    ret[idx] = e; -- [LINE 666]
    idx = (idx + 1); -- [LINE 666]
    return table.concat(ret); -- [LINE 668]
  end;
  setfenv(make_repr, _G);
  return getfenv();
end)(getfenv());
LuaValueOnlySequance = setup_basic_class(LuaValueOnlySequance);
LuaValueOnlySequance = setup_hide_class(LuaValueOnlySequance);
list = (function(_G) -- (class list:LuaValueOnlySequance)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaValueOnlySequance}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __bases__ = {LuaValueOnlySequance};
  __name__ = 'list';
  function __repr__(self)
    return self.make_repr('[', ']'); -- [LINE 674]
  end;
  setfenv(__repr__, _G);
  function __setattr__(self, key, value)
    error('Not allowed'); -- [LINE 677]
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
  __bases__ = {LuaValueOnlySequance};
  __name__ = 'tuple';
  function __repr__(self)
    return self.make_repr('(', ')'); -- [LINE 683]
  end;
  setfenv(__repr__, _G);
  function __setattr__(self, key, value)
    error('Not allowed'); -- [LINE 686]
  end;
  setfenv(__setattr__, _G);
  function __len__(self)
    return int(lua.len(ObjValue[self])); -- [LINE 689]
  end;
  setfenv(__len__, _G);
  function __getitem__(self, x)
    assert(is_pyobj(x)); -- [LINE 692]
    if isinstance(x, int) then -- [LINE 693]
      return ObjValue[self][(LObj(x) + 1)]; -- [LINE 694]
    end;
    error('Not support unknown type.'); -- [LINE 696]
  end;
  setfenv(__getitem__, _G);
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
  __bases__ = {LuaObject};
  __name__ = 'str';
  function __init__(self, value)
    if is_pyobj(value) then -- [LINE 702]
      value = _OP__Str__(value); -- [LINE 703]
      value = LObj(value); -- [LINE 704]
    end;
    ObjValue[self] = value; -- [LINE 706]
  end;
  setfenv(__init__, _G);
  function __str__(self)
    return self; -- [LINE 709]
  end;
  setfenv(__str__, _G);
  function __repr__(self)
    return str(lua.concat("'", ObjValue[self], "'")); -- [LINE 712]
  end;
  setfenv(__repr__, _G);
  function __len__(self)
    return int(lua.len(ObjValue[self])); -- [LINE 715]
  end;
  setfenv(__len__, _G);
  return getfenv();
end)(getfenv());
str = setup_basic_class(str);
bool = (function(_G) -- (class bool:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __bases__ = {LuaObject};
  __name__ = 'bool';
  function __new__(cls, value)
    if not inited then -- [LINE 721]
      local instance = object.__new__(cls); -- [LINE 722]
      ObjValue[instance] = value; -- [LINE 723]
      return instance; -- [LINE 724]
    end;
    if is_pyobj(value) then -- [LINE 726]
      value = _OP__Bool__(value); -- [LINE 727]
    else
      value = value and true or false; -- [LINE 730]
    end;
    if value == true then -- [LINE 732]
      return True; -- [LINE 733]
    elseif value == false then -- [LINE 734]
      return False; -- [LINE 735]
    elseif is_pyobj(value) and type(value) == bool then -- [LINE 736]
      return value; -- [LINE 737]
    end;
    error('__Bool__ are returned unknown value.'); -- [LINE 739]
  end;
  setfenv(__new__, _G);
  function __repr__(self)
    local value = ObjValue[self]; -- [LINE 742]
    if value == true then -- [LINE 743]
      return str('True'); -- [LINE 744]
    elseif value == false then -- [LINE 745]
      return str('False'); -- [LINE 746]
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
  __bases__ = {LuaObject};
  __name__ = 'int';
  function __add__(self, other)
    return int((ObjValue[self] + ObjValue[other])); -- [LINE 754]
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
  __bases__ = {LuaObject};
  __name__ = 'dict';
  return getfenv();
end)(getfenv());
dict = setup_basic_class(dict);
local function inital()
  local cls, value;
  for cls, value in pairs(IsBuiltinTypes) do -- [LINE 764]
    assert(value == false); -- [LINE 765]
    register_builtins_class(cls); -- [LINE 766]
  end;
  _M['NotImplemented'] = NotImplementedType(); -- [LINE 768]
  _M['Ellipsis'] = EllipsisType(); -- [LINE 769]
  _M['None'] = NoneType(); -- [LINE 770]
  _M['True'] = bool(true); -- [LINE 771]
  _M['False'] = bool(false); -- [LINE 772]
  return true; -- [LINE 774]
end;
inited = inital(); -- [LINE 776]
local x = list({int(1), int(2), int(3)}); -- [LINE 781]
local y = int(5); -- [LINE 782]
local z = int(7); -- [LINE 783]
print(x); -- [LINE 785]
print(True == nil); -- [LINE 786]
print(True); -- [LINE 787]
print(issubclass(int, object)); -- [LINE 788]
print(int.mro()); -- [LINE 789]
print(_OP__Add__(y, z)); -- [LINE 790]
error(Exception(str('test'))); -- [LINE 791]
