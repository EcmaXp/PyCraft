local _M = getfenv(1);
if pyscripter then -- [LINE 1]
  exit(__import__('pc').main()); -- [LINE 1]
end;
 -- [LINE 3]
local _M = setmetatable({['_G'] = _G}, {['__index'] = _G}); -- [LINE 4]
setfenv(1, _M); -- [LINE 5]
lua = {}; -- [LINE 8]
lua.len = (function(obj) return #obj; end); -- [LINE 9]
lua.concat = (function(...) return table.concat({...}); end); -- [LINE 10]
lua.write = write or io.write; -- [LINE 11]
local key, value;
for key, value in pairs(_G) do -- [LINE 12]
  lua[key] = value; -- [LINE 13]
end;
local PY_OBJ_TAG = '#'; -- [LINE 15]
local LUA_OBJ_TAG = '@'; -- [LINE 16]
local TAG = '[PY]'; -- [LINE 18]
local ObjLastID = 0; -- [LINE 19]
local inited = False; -- [LINE 20]
local builtins = 'builtins'; -- [LINE 22]
local ObjID = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 25]
local ObjValue = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 26]
local ObjPCEX = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 27]
local Obj_FromID = setmetatable({}, {['__mode'] = 'v'}); -- [LINE 28]
local BuiltinTypes = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 29]
local InitalBuiltinTypes = {}; -- [LINE 33]
local builtin_methods = {'__new__', '__init__', '__del__', '__repr__', '__str__', '__bytes__', '__format__', '__lt__', '__le__', '__eq__', '__ne__', '__gt__', '__ge__', '__hash__', '__bool__', '__getattr__', '__getattribute__', '__setattr__', '__delattr__', '__dir__', '__get__', '__set__', '__delete__', '__slots__', '__call__', '__len__', '__getitem__', '__setitem__', '__delitem__', '__iter__', '__reversed__', '__contains__', '__add__', '__sub__', '__mul__', '__truediv__', '__floordiv__', '__mod__', '__divmod__', '__pow__', '__lshift__', '__rshift__', '__and__', '__xor__', '__or__', '__radd__', '__rsub__', '__rmul__', '__rtruediv__', '__rfloordiv__', '__rmod__', '__rdivmod__', '__rpow__', '__rlshift__', '__rrshift__', '__rand__', '__rxor__', '__ror__', '__iadd__', '__isub__', '__imul__', '__itruediv__', '__ifloordiv__', '__imod__', '__ipow__', '__ilshift__', '__irshift__', '__iand__', '__ixor__', '__ior__', '__neg__', '__pos__', '__abs__', '__invert__', '__complex__', '__int__', '__float__', '__round__', '__index__', '__enter__', '__exit__', '__lua__'}; -- [LINE 36]
local builtin_methods_rev = {}; -- [LINE 37]
local k, v;
for k, v in pairs(builtin_methods) do -- [LINE 38]
  builtin_methods_rev[v] = k; -- [LINE 39]
end;
assert(builtin_methods[42] == '__rshift__'); -- [LINE 41]
assert(builtin_methods_rev['__pos__'] == 72); -- [LINE 42]
local error = nil; -- [LINE 43]
local function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 46]
    error('This is not number', 2); -- [LINE 47]
  end;
  return math.floor(num) ~= num; -- [LINE 49]
end;
local function is_pyobj(obj)
  return ObjID[obj] ~= nil; -- [LINE 52]
end;
local function PObj(obj)
  if is_pyobj(obj) then -- [LINE 55]
    return obj; -- [LINE 56]
  else
    return LuaObject(obj); -- [LINE 58]
  end;
end;
local function LObj(obj)
  if is_pyobj(obj) then -- [LINE 61]
    return _OP__Lua__(obj); -- [LINE 62]
  else
    return obj; -- [LINE 64]
  end;
end;
local function require_pyobj(...)
  local objs = {...};
  local idx, obj;
  for idx, obj in pairs(objs) do -- [LINE 67]
    if not is_pyobj(obj) then -- [LINE 68]
      lua.print(lua.type(obj), obj); -- [LINE 69]
      error('Require python object.'); -- [LINE 70]
    end;
  end;
  return true; -- [LINE 72]
end;
local function register_pyobj(obj)
  ObjLastID = (ObjLastID + 1); -- [LINE 76]
  local obj_id = ObjLastID; -- [LINE 77]
  ObjID[obj] = obj_id; -- [LINE 79]
  Obj_FromID[obj_id] = obj; -- [LINE 80]
  return obj; -- [LINE 81]
end;
function error(msg, level)
  if level == nil then -- [LINE 84]
    level = 1; -- [LINE 85]
  end;
  if is_pyobj(msg) then -- [LINE 87]
    msg = LObj(msg); -- [LINE 88]
  end;
  level = (level + 1); -- [LINE 90]
  lua.error(lua.concat(TAG, ' ', tostring(msg)), level); -- [LINE 91]
end;
local function require_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 94]
    if value == nil then -- [LINE 95]
      error('SystemError: Not Enough Item'); -- [LINE 96]
    end;
  end;
  return True; -- [LINE 98]
end;
local function nonrequire_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 101]
    if value ~= nil then -- [LINE 102]
      error('SystemError: Not Enough Item'); -- [LINE 103]
    end;
  end;
  return True; -- [LINE 105]
end;
function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 108]
    error('This is not number', 2); -- [LINE 109]
  end;
  return math.floor(num) ~= num; -- [LINE 111]
end;
local function setup_base_class(cls)
  local pcex = {}; -- [LINE 114]
  local k, v;
  for k, v in pairs(cls) do -- [LINE 115]
    local idx = builtin_methods_rev[k]; -- [LINE 116]
    if idx ~= nil then -- [LINE 117]
      pcex[idx] = v; -- [LINE 118]
    end;
  end;
  ObjPCEX[cls] = pcex; -- [LINE 120]
  InitalBuiltinTypes[cls] = false; -- [LINE 121]
  register_pyobj(cls); -- [LINE 122]
  return cls; -- [LINE 124]
end;
local function setup_basic_class(cls)
  setup_base_class(cls); -- [LINE 127]
  setmetatable(cls, type); -- [LINE 128]
  return cls; -- [LINE 130]
end;
local function setup_hide_class(cls)
  InitalBuiltinTypes[cls] = nil; -- [LINE 133]
  return cls; -- [LINE 134]
end;
local function register_builtins_class(cls)
  local idx = 1; -- [LINE 137]
  local mro = {}; -- [LINE 138]
  mro[idx] = cls; -- [LINE 140]
  idx = (idx + 1); -- [LINE 141]
  local bases = rawget(cls, '__bases__'); -- [LINE 143]
  if bases ~= nil then -- [LINE 144]
    for i = #bases, 1, -1 do --; -- [LINE 145]
    if true then -- [LINE 146]
      local base = bases[i]; -- [LINE 147]
      if InitalBuiltinTypes[base] ~= nil then -- [LINE 148]
        mro[idx] = base; -- [LINE 149]
        idx = (idx + 1); -- [LINE 150]
      end;
    end;
    end; -- [LINE 151]
  end;
  if cls ~= object then -- [LINE 153]
    mro[idx] = object; -- [LINE 154]
    idx = (idx + 1); -- [LINE 155]
  end;
  rawset(cls, '__bases__', nil); -- [LINE 157]
  rawset(cls, '__name__', str(rawget(cls, '__name__'))); -- [LINE 158]
  rawset(cls, '__module__', str('builtins')); -- [LINE 159]
  rawset(cls, '__mro__', tuple(mro)); -- [LINE 160]
  InitalBuiltinTypes[cls] = true; -- [LINE 162]
  return cls; -- [LINE 163]
end;
local function Fail_OP(a, ax)
  error(lua.concat(LObj(repr(a)), ' are not support ', builtin_methods[ax])); -- [LINE 166]
end;
local function Fail_OP_Raw(a, raw_ax)
  error(lua.concat(LObj(repr(a)), ' are not support ', raw_ax)); -- [LINE 169]
end;
local function Fail_OP_Math_Raw(a, b, raw_ax)
  error(lua.concat('Not support ', LObj(repr(a)), ' ', raw_ax, ' ', LObj(repr(b)))); -- [LINE 172]
end;
local function Fail_OP_Math(a, b, ax, extra)
  if extra == nil then -- [LINE 175]
    extra = ''; -- [LINE 176]
  else
    extra = lua.concat(' ', extra); -- [LINE 178]
  end;
  error(lua.concat('Not support ', LObj(repr(a)), ' ', builtin_methods[ax], ' ', LObj(repr(b)), extra)); -- [LINE 180]
end;
local function Fail_OP_Math_Pow(a, b, ax, c)
  local extra = ''; -- [LINE 183]
  if c then -- [LINE 184]
    extra = lua.concat('% ', LObj(repr(c))); -- [LINE 185]
  end;
  Fail_OP_Math(a, b, ax, c); -- [LINE 187]
end;
local function OP_Call(ax)
  local function func(a, ...)
    local args = {...};
    assert(require_pyobj(a)); -- [LINE 191]
    local f = ObjPCEX[getmetatable(a)][ax]; -- [LINE 192]
    if f then -- [LINE 193]
      return f(a, ...); -- [LINE 194]
    end;
    Fail_OP(a, ax); -- [LINE 196]
  end;
  return func; -- [LINE 197]
end;
local function OP_Math2(ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 201]
    local am = ObjPCEX[getmetatable(a)]; -- [LINE 202]
    local bm = ObjPCEX[getmetatable(b)]; -- [LINE 203]
    local f = am[ax]; -- [LINE 205]
    if f then -- [LINE 206]
      local ret = f(a, b); -- [LINE 207]
      if ret ~= NotImplemented then -- [LINE 208]
        return ret; -- [LINE 208]
      end;
    end;
    f = bm[bx]; -- [LINE 210]
    if f then -- [LINE 211]
      ret = f(b, a); -- [LINE 212]
      if ret ~= NotImplemented then -- [LINE 213]
        return ret; -- [LINE 213]
      end;
    end;
    Fail_OP_Math(a, b, ax); -- [LINE 215]
  end;
  return func; -- [LINE 217]
end;
local function OP_Math3(cx, ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 221]
    local am = ObjPCEX[getmetatable(a)]; -- [LINE 222]
    local bm = ObjPCEX[getmetatable(b)]; -- [LINE 223]
    local is_n = isinstance(a, int) == True or isinstance(b, float) == True; -- [LINE 224]
    if is_n then -- [LINE 226]
      local f = am[ax]; -- [LINE 227]
      if f then -- [LINE 228]
        local ret = f(a, b); -- [LINE 229]
        if ret ~= NotImplemented then -- [LINE 230]
          return ret; -- [LINE 230]
        end;
      end;
    end;
    f = am[cx]; -- [LINE 232]
    if f then -- [LINE 233]
      ret = f(a, b); -- [LINE 234]
      if ret ~= NotImplemented then -- [LINE 235]
        return ret; -- [LINE 235]
      end;
    end;
    if not is_n then -- [LINE 238]
      f = am[ax]; -- [LINE 239]
      if f then -- [LINE 240]
        ret = f(a, b); -- [LINE 241]
        if ret ~= NotImplemented then -- [LINE 242]
          return ret; -- [LINE 242]
        end;
      end;
    end;
    f = bm[bx]; -- [LINE 244]
    if f then -- [LINE 245]
      ret = f(b, a); -- [LINE 246]
      if ret ~= NotImplemented then -- [LINE 247]
        return ret; -- [LINE 247]
      end;
    end;
    Fail_OP_Math(a, b, cx); -- [LINE 249]
  end;
  return func; -- [LINE 251]
end;
local function OP_Math2_Pow(ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 255]
    assert(require_pyobj(c) or c == nil); -- [LINE 256]
    local am = ObjPCEX[getmetatable(a)]; -- [LINE 257]
    local bm = ObjPCEX[getmetatable(b)]; -- [LINE 258]
    local f = am[ax]; -- [LINE 260]
    if f then -- [LINE 261]
      local ret = f(a, b, c); -- [LINE 262]
      if ret ~= NotImplemented then -- [LINE 263]
        return ret; -- [LINE 263]
      end;
    end;
    if c ~= nil then -- [LINE 265]
      f = bm[bx]; -- [LINE 270]
      if f then -- [LINE 271]
        ret = f(b, a); -- [LINE 272]
        if ret ~= NotImplemented then -- [LINE 273]
          return ret; -- [LINE 273]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 275]
  end;
  return func; -- [LINE 277]
end;
local function OP_Math3_Pow(cx, ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 281]
    assert(require_pyobj(c) or c == nil); -- [LINE 282]
    local am = ObjPCEX[getmetatable(a)]; -- [LINE 283]
    local bm = ObjPCEX[getmetatable(b)]; -- [LINE 284]
    local f = am[cx]; -- [LINE 286]
    if f then -- [LINE 287]
      local ret = f(a, b, c); -- [LINE 288]
      if ret ~= NotImplemented then -- [LINE 289]
        return ret; -- [LINE 289]
      end;
    end;
    f = am[ax]; -- [LINE 291]
    if f then -- [LINE 292]
      ret = f(a, b, c); -- [LINE 293]
      if ret ~= NotImplemented then -- [LINE 294]
        return ret; -- [LINE 294]
      end;
    end;
    if c ~= nil then -- [LINE 296]
      f = bm[bx]; -- [LINE 297]
      if f then -- [LINE 298]
        ret = f(b, a); -- [LINE 299]
        if ret ~= NotImplemented then -- [LINE 300]
          return ret; -- [LINE 300]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 302]
  end;
  return func; -- [LINE 304]
end;
function _OP__Is__(a, b)
  require_pyobj(a, b); -- [LINE 308]
  return ObjID[a] == ObjID[b]; -- [LINE 309]
end;
function _OP__IsNot__(a, b)
  return not _OP__Is__(a, b); -- [LINE 312]
end;
local function _(name)
  return builtin_methods_rev[name]; -- [LINE 314]
end;
 -- [LINE 315]
_OP__New__ = OP_Call(_('__new__')); -- [LINE 317]
_OP__Init__ = OP_Call(_('__init__')); -- [LINE 318]
_OP__Del__ = OP_Call(_('__del__')); -- [LINE 319]
_OP__Repr__ = OP_Call(_('__repr__')); -- [LINE 320]
_OP__Str__ = OP_Call(_('__str__')); -- [LINE 321]
_OP__Bytes__ = OP_Call(_('__bytes__')); -- [LINE 322]
_OP__Format__ = OP_Call(_('__format__')); -- [LINE 323]
_OP__Lt__ = OP_Call(_('__lt__')); -- [LINE 324]
_OP__Le__ = OP_Call(_('__le__')); -- [LINE 325]
_OP__Eq__ = OP_Call(_('__eq__')); -- [LINE 326]
_OP__Ne__ = OP_Call(_('__ne__')); -- [LINE 327]
_OP__Gt__ = OP_Call(_('__gt__')); -- [LINE 328]
_OP__Ge__ = OP_Call(_('__ge__')); -- [LINE 329]
_OP__Hash__ = OP_Call(_('__hash__')); -- [LINE 330]
_OP__Bool__ = OP_Call(_('__bool__')); -- [LINE 331]
_OP__Getattr__ = OP_Call(_('__getattr__')); -- [LINE 332]
_OP__Getattribute__ = OP_Call(_('__getattribute__')); -- [LINE 333]
_OP__Setattr__ = OP_Call(_('__setattr__')); -- [LINE 334]
_OP__Delattr__ = OP_Call(_('__delattr__')); -- [LINE 335]
_OP__Dir__ = OP_Call(_('__dir__')); -- [LINE 336]
_OP__Get__ = OP_Call(_('__get__')); -- [LINE 337]
_OP__Set__ = OP_Call(_('__set__')); -- [LINE 338]
_OP__Delete__ = OP_Call(_('__delete__')); -- [LINE 339]
_OP__Slots__ = OP_Call(_('__slots__')); -- [LINE 340]
_OP__Call__ = OP_Call(_('__call__')); -- [LINE 341]
_OP__Len__ = OP_Call(_('__len__')); -- [LINE 342]
_OP__Getitem__ = OP_Call(_('__getitem__')); -- [LINE 343]
_OP__Setitem__ = OP_Call(_('__setitem__')); -- [LINE 344]
_OP__Delitem__ = OP_Call(_('__delitem__')); -- [LINE 345]
_OP__Iter__ = OP_Call(_('__iter__')); -- [LINE 346]
_OP__Reversed__ = OP_Call(_('__reversed__')); -- [LINE 347]
_OP__Contains__ = OP_Call(_('__contains__')); -- [LINE 348]
_OP__Add__ = OP_Math2(_('__add__'), _('__radd__')); -- [LINE 351]
_OP__Sub__ = OP_Math2(_('__sub__'), _('__rsub__')); -- [LINE 352]
_OP__Mul__ = OP_Math2(_('__mul__'), _('__rmul__')); -- [LINE 353]
_OP__Truediv__ = OP_Math2(_('__truediv__'), _('__rtruediv__')); -- [LINE 354]
_OP__Floordiv__ = OP_Math2(_('__floordiv__'), _('__rfloordiv__')); -- [LINE 355]
_OP__Mod__ = OP_Math2(_('__mod__'), _('__rmod__')); -- [LINE 356]
_OP__Divmod__ = OP_Math2(_('__divmod__'), _('__rdivmod__')); -- [LINE 357]
_OP__Pow__ = OP_Math2_Pow(_('__pow__'), _('__rpow__')); -- [LINE 358]
_OP__Lshift__ = OP_Math2(_('__lshift__'), _('__rlshift__')); -- [LINE 359]
_OP__Rshift__ = OP_Math2(_('__rshift__'), _('__rrshift__')); -- [LINE 360]
_OP__And__ = OP_Math2(_('__and__'), _('__rand__')); -- [LINE 361]
_OP__Xor__ = OP_Math2(_('__xor__'), _('__rxor__')); -- [LINE 362]
_OP__Or__ = OP_Math2(_('__or__'), _('__ror__')); -- [LINE 363]
_OP__Iadd__ = OP_Math3(_('__iadd__'), _('__add__'), _('__radd__')); -- [LINE 366]
_OP__Isub__ = OP_Math3(_('__isub__'), _('__sub__'), _('__rsub__')); -- [LINE 367]
_OP__Imul__ = OP_Math3(_('__imul__'), _('__mul__'), _('__rmul__')); -- [LINE 368]
_OP__Itruediv__ = OP_Math3(_('__itruediv__'), _('__truediv__'), _('__rtruediv__')); -- [LINE 369]
_OP__Ifloordiv__ = OP_Math3(_('__ifloordiv__'), _('__floordiv__'), _('__rfloordiv__')); -- [LINE 370]
_OP__Imod__ = OP_Math3(_('__imod__'), _('__mod__'), _('__rmod__')); -- [LINE 371]
_OP__Ipow__ = OP_Math3_Pow(_('__ipow__'), _('__pow__'), _('__rpow__')); -- [LINE 372]
_OP__Ilshift__ = OP_Math3(_('__ilshift__'), _('__lshift__'), _('__rlshift__')); -- [LINE 373]
_OP__Irshift__ = OP_Math3(_('__irshift__'), _('__rshift__'), _('__rrshift__')); -- [LINE 374]
_OP__Iand__ = OP_Math3(_('__iand__'), _('__and__'), _('__rand__')); -- [LINE 375]
_OP__Ixor__ = OP_Math3(_('__ixor__'), _('__xor__'), _('__rxor__')); -- [LINE 376]
_OP__Ior__ = OP_Math3(_('__ior__'), _('__or__'), _('__ror__')); -- [LINE 377]
_OP__Neg__ = OP_Call(_('__neg__')); -- [LINE 380]
_OP__Pos__ = OP_Call(_('__pos__')); -- [LINE 381]
_OP__Abs__ = OP_Call(_('__abs__')); -- [LINE 382]
_OP__Invert__ = OP_Call(_('__invert__')); -- [LINE 383]
_OP__Complex__ = OP_Call(_('__complex__')); -- [LINE 384]
_OP__Int__ = OP_Call(_('__int__')); -- [LINE 385]
_OP__Float__ = OP_Call(_('__float__')); -- [LINE 386]
_OP__Round__ = OP_Call(_('__round__')); -- [LINE 387]
_OP__Index__ = OP_Call(_('__index__')); -- [LINE 388]
_OP__Enter__ = OP_Call(_('__enter__')); -- [LINE 389]
_OP__Exit__ = OP_Call(_('__exit__')); -- [LINE 390]
_OP__Lua__ = OP_Call(_('__lua__')); -- [LINE 393]
function repr(obj)
  if is_pyobj(obj) then -- [LINE 397]
    return _OP__Repr__(obj); -- [LINE 398]
  else
    return lua.concat(LUA_OBJ_TAG, '(', tostring(obj), ')'); -- [LINE 400]
  end;
end;
function print(...)
  local args = {...};
  local arr = {}; -- [LINE 403]
  local idx = 1; -- [LINE 404]
  local _, arg;
  for _, arg in pairs(args) do -- [LINE 406]
    if is_pyobj(arg) then -- [LINE 407]
      arg = str(arg); -- [LINE 408]
    else
      arg = repr(arg); -- [LINE 410]
    end;
    arg = LObj(arg); -- [LINE 412]
    arr[idx] = arg; -- [LINE 414]
    idx = (idx + 1); -- [LINE 415]
  end;
  local data = table.concat(arr, ' '); -- [LINE 417]
  data = lua.concat(data, '\n'); -- [LINE 418]
  lua.write(data); -- [LINE 419]
end;
function isinstance(obj, targets)
  require_pyobj(obj); -- [LINE 422]
  local cls = type(obj); -- [LINE 424]
  local mro = cls.mro(); -- [LINE 425]
  assert(type(mro) == list); -- [LINE 426]
  local _, supercls;
  for _, supercls in pairs(ObjValue[mro]) do -- [LINE 428]
    require_pyobj(supercls); -- [LINE 429]
    if supercls == targets then -- [LINE 430]
      return True; -- [LINE 431]
    end;
  end;
  return False; -- [LINE 433]
end;
function issubclass(cls, targets)
  require_pyobj(obj); -- [LINE 436]
  if type(cls) ~= type then -- [LINE 438]
    error('issubclass() arg 1 must be a class'); -- [LINE 439]
  end;
  local mro = cls.mro(); -- [LINE 441]
  assert(type(mro) == list); -- [LINE 442]
  local _, supercls;
  for _, supercls in pairs(ObjValue[mro]) do -- [LINE 444]
    require_pyobj(supercls); -- [LINE 445]
    if supercls == targets then -- [LINE 446]
      return True; -- [LINE 447]
    end;
  end;
  return False; -- [LINE 449]
end;
function id(obj)
  if is_pyobj(obj) then -- [LINE 452]
    return int(ObjID[obj]); -- [LINE 453]
  end;
  Fail_OP_Raw(obj, '__id!'); -- [LINE 455]
end;
function len(obj)
  return _OP__Len__(obj); -- [LINE 458]
end;
 -- [LINE 460]
_ = nil; -- [LINE 461]
object = (function(_M)--(object)
  local scope = setmetatable({}, {__index=_M})
;scope.__name__ = 'object';
  function doload()
    function __init__(self)
    end;
    setfenv(__init__, _M);
    function __call(self, ...)
      local args = {...};
      return _OP__Call__(self, ...); -- [LINE 471]
    end;
    setfenv(__call, _M);
    function __index(self, key)
      return _OP__Getattribute__(self, key); -- [LINE 474]
    end;
    setfenv(__index, _M);
    function __newindex(self, key, value)
      return _OP__Setattr__(self, key, value); -- [LINE 477]
    end;
    setfenv(__newindex, _M);
    function __tostring(self)
      return lua.concat(PY_OBJ_TAG, '(', LObj(repr(self)), ')'); -- [LINE 480]
    end;
    setfenv(__tostring, _M);
    function __new__(cls, ...)
      local args = {...};
      local instance = {}; -- [LINE 483]
      instance = register_pyobj(instance); -- [LINE 484]
      lua.setmetatable(instance, cls); -- [LINE 485]
      _OP__Init__(instance, ...); -- [LINE 486]
      return instance; -- [LINE 488]
    end;
    setfenv(__new__, _M);
    function __getattribute__(self, k)
      local v = rawget(self, k); -- [LINE 491]
      if v ~= nil then -- [LINE 492]
        return v; -- [LINE 493]
      end;
      local mt = getmetatable(self); -- [LINE 495]
      v = rawget(mt, k); -- [LINE 496]
      if v ~= nil then -- [LINE 497]
        if lua.type(v) == 'function' then -- [LINE 498]
          return (function(...) return v(self, unpack({...})); end); -- [LINE 499]
        else
          return v; -- [LINE 501]
        end;
      end;
      error(lua.concat("Not found '", k, "' attribute.")); -- [LINE 503]
    end;
    setfenv(__getattribute__, _M);
    function __setattr__(self, key, value)
      if BuiltinTypes[type(self)] and inited then -- [LINE 506]
        error("TypeError: can't set attributes of built-in/extension type 'object'"); -- [LINE 507]
      end;
      rawset(self, key, value); -- [LINE 510]
    end;
    setfenv(__setattr__, _M);
    function __str__(self)
      return _OP__Repr__(self); -- [LINE 513]
    end;
    setfenv(__str__, _M);
    function __repr__(self)
      local mtable = getmetatable(self); -- [LINE 516]
      return str(lua.concat('<object ', LObj(mtable.__name__), ' at ', LObj(id(self)), '>')); -- [LINE 517]
    end;
    setfenv(__repr__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
object = setup_base_class(object);
type = (function(_M)--(type: object)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {object};
  scope.__name__ = 'type';
  function doload()
    function __call__(cls, ...)
      local args = {...};
      local instance = cls.__new__(cls, ...); -- [LINE 523]
      register_pyobj(instance); -- [LINE 524]
      return instance; -- [LINE 526]
    end;
    setfenv(__call__, _M);
    function __repr__(cls)
      return str(lua.concat("<class '", LObj(cls.__name__), "'>")); -- [LINE 529]
    end;
    setfenv(__repr__, _M);
    function mro(cls)
      return list(ObjValue[cls.__mro__]); -- [LINE 532]
    end;
    setfenv(mro, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
type = setup_base_class(type);
local ptype = (function(_M)--(ptype: type)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({type}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {type};
  scope.__name__ = 'ptype';
  function doload()
    function __call__(cls, ...)
      local args = {...};
      if lua.len(args) == 1 then -- [LINE 537]
        require_pyobj(args[1]); -- [LINE 538]
        return getmetatable(args[1]); -- [LINE 539]
      elseif lua.len(args) == 3 then -- [LINE 540]
      else
        error('Unexcepted arguments.'); -- [LINE 543]
      end;
    end;
    setfenv(__call__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
ptype = setup_base_class(ptype);
setmetatable(object, type); -- [LINE 545]
setmetatable(type, ptype); -- [LINE 546]
setmetatable(ptype, ptype); -- [LINE 547]
local BaseException = (function(_M)--(BaseException: object)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {object};
  scope.__name__ = 'BaseException';
  function doload()
    args = nil; -- [LINE 553]
    function __new__(cls, ...)
      local args = {...};
      local param = tuple(args); -- [LINE 556]
      local instance = object.__new__(cls); -- [LINE 557]
      rawset(instance, 'args', param); -- [LINE 558]
      _OP__Init__(instance, param); -- [LINE 559]
      return instance; -- [LINE 560]
    end;
    setfenv(__new__, _M);
    function __str__(self)
      local length = LObj(len(self.args)); -- [LINE 563]
      if length == 0 then -- [LINE 564]
        return str(''); -- [LINE 565]
      elseif length == 1 then -- [LINE 566]
        return str(_OP__Getitem__(self.args, int(0))); -- [LINE 567]
      end;
    end;
    setfenv(__str__, _M);
    function __repr__(self)
      local excname = LObj(type(self).__name__); -- [LINE 570]
      return lua.concat(excname, repr(self.args)); -- [LINE 571]
    end;
    setfenv(__repr__, _M);
    function __lua__(self)
      local excname = LObj(type(self).__name__); -- [LINE 574]
      local value = str(self); -- [LINE 575]
      if LObj(len(value)) > 0 then -- [LINE 577]
        return lua.concat(excname, ': ', LObj(value)); -- [LINE 578]
      else
        return lua.concat(excname); -- [LINE 580]
      end;
    end;
    setfenv(__lua__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
BaseException = setup_basic_class(BaseException);
local Exception = (function(_M)--(Exception: BaseException)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({BaseException}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {BaseException};
  scope.__name__ = 'Exception';
  function doload()
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
Exception = setup_basic_class(Exception);
local UnstableException = (function(_M)--(UnstableException: Exception, BaseException)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({BaseException, Exception}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {Exception, BaseException};
  scope.__name__ = 'UnstableException';
  function doload()
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
UnstableException = setup_basic_class(UnstableException);
local BuiltinConstType = (function(_M)--(BuiltinConstType: object)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {object};
  scope.__name__ = 'BuiltinConstType';
  function doload()
    function __new__(cls, ...)
      local args = {...};
      if not inited then -- [LINE 593]
        local instance = object.__new__(cls, ...); -- [LINE 594]
        _OP__Init__(instance, ...); -- [LINE 595]
        return instance; -- [LINE 596]
      end;
      return cls._get_singleton(); -- [LINE 598]
    end;
    setfenv(__new__, _M);
    function _get_singleton(cls)
      error('Not defined.'); -- [LINE 601]
    end;
    setfenv(_get_singleton, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
BuiltinConstType = setup_basic_class(BuiltinConstType);
local NotImplementedType = (function(_M)--(NotImplementedType: BuiltinConstType)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({BuiltinConstType}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {BuiltinConstType};
  scope.__name__ = 'NotImplementedType';
  function doload()
    function _get_singleton(cls)
      return NotImplemented; -- [LINE 606]
    end;
    setfenv(_get_singleton, _M);
    function __repr__(self)
      return str('NotImplemented'); -- [LINE 609]
    end;
    setfenv(__repr__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
NotImplementedType = setup_basic_class(NotImplementedType);
local EllipsisType = (function(_M)--(EllipsisType: BuiltinConstType)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({BuiltinConstType}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {BuiltinConstType};
  scope.__name__ = 'EllipsisType';
  function doload()
    function _get_singleton(self)
      return Ellipsis; -- [LINE 614]
    end;
    setfenv(_get_singleton, _M);
    function __repr__(self)
      return str('Ellipsis'); -- [LINE 617]
    end;
    setfenv(__repr__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
EllipsisType = setup_basic_class(EllipsisType);
local NoneType = (function(_M)--(NoneType: BuiltinConstType)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({BuiltinConstType}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {BuiltinConstType};
  scope.__name__ = 'NoneType';
  function doload()
    function _get_singleton(cls)
      return None; -- [LINE 622]
    end;
    setfenv(_get_singleton, _M);
    function __repr__(self)
      return str('None'); -- [LINE 625]
    end;
    setfenv(__repr__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
NoneType = setup_basic_class(NoneType);
local LuaObject = (function(_M)--(LuaObject: object)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {object};
  scope.__name__ = 'LuaObject';
  function doload()
    LuaObject = true; -- [LINE 631]
    function __init__(self, obj)
      local mtable = getmetatable(obj); -- [LINE 635]
      if mtable and rawget(mtable, 'LuaObject') then -- [LINE 636]
        obj = LObj(obj); -- [LINE 637]
      end;
      ObjValue[self] = obj; -- [LINE 639]
    end;
    setfenv(__init__, _M);
    function __str__(self)
      return str(_OP__Repr__(self)); -- [LINE 642]
    end;
    setfenv(__str__, _M);
    function __repr__(self)
      return str(tostring(ObjValue[self])); -- [LINE 645]
    end;
    setfenv(__repr__, _M);
    function __lua__(self)
      return ObjValue[self]; -- [LINE 648]
    end;
    setfenv(__lua__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
LuaObject = setup_basic_class(LuaObject);
LuaObject = setup_hide_class(LuaObject);
local LuaValueOnlySequance = (function(_M)--(LuaValueOnlySequance: LuaObject)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {LuaObject};
  scope.__name__ = 'LuaValueOnlySequance';
  function doload()
    function __init__(self, value)
      if is_pyobj(value) then -- [LINE 654]
        self.check_type(value); -- [LINE 655]
      end;
      ObjValue[self] = value; -- [LINE 657]
    end;
    setfenv(__init__, _M);
    function check_type(self, value)
      if type(value) == 'table' then -- [LINE 660]
      elseif value[lua.len(value)] == nil then -- [LINE 661]
      elseif value[1] == nil then -- [LINE 662]
      elseif value[0] ~= nil then -- [LINE 663]
      else
        return true; -- [LINE 665]
      end;
      return false; -- [LINE 667]
    end;
    setfenv(check_type, _M);
    function make_repr(self, s, e)
      local ret = {}; -- [LINE 670]
      local idx = 1; -- [LINE 671]
      local sep = ''; -- [LINE 673]
      ret[idx] = s; -- [LINE 674]
      idx = (idx + 1); -- [LINE 674]
      local k, v;
      for k, v in pairs(ObjValue[self]) do -- [LINE 675]
        ret[idx] = sep; -- [LINE 676]
        idx = (idx + 1); -- [LINE 676]
        ret[idx] = LObj(repr(v)); -- [LINE 677]
        idx = (idx + 1); -- [LINE 677]
        sep = ', '; -- [LINE 678]
      end;
      ret[idx] = e; -- [LINE 680]
      idx = (idx + 1); -- [LINE 680]
      return table.concat(ret); -- [LINE 682]
    end;
    setfenv(make_repr, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
LuaValueOnlySequance = setup_basic_class(LuaValueOnlySequance);
LuaValueOnlySequance = setup_hide_class(LuaValueOnlySequance);
list = (function(_M)--(list: LuaValueOnlySequance)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({LuaValueOnlySequance}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {LuaValueOnlySequance};
  scope.__name__ = 'list';
  function doload()
    function __repr__(self)
      return self.make_repr('[', ']'); -- [LINE 688]
    end;
    setfenv(__repr__, _M);
    function __setattr__(self, key, value)
      error('Not allowed'); -- [LINE 691]
    end;
    setfenv(__setattr__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
list = setup_basic_class(list);
tuple = (function(_M)--(tuple: LuaValueOnlySequance)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({LuaValueOnlySequance}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {LuaValueOnlySequance};
  scope.__name__ = 'tuple';
  function doload()
    function __repr__(self)
      return self.make_repr('(', ')'); -- [LINE 697]
    end;
    setfenv(__repr__, _M);
    function __setattr__(self, key, value)
      error('Not allowed'); -- [LINE 700]
    end;
    setfenv(__setattr__, _M);
    function __len__(self)
      return int(lua.len(ObjValue[self])); -- [LINE 703]
    end;
    setfenv(__len__, _M);
    function __getitem__(self, x)
      assert(is_pyobj(x)); -- [LINE 706]
      if isinstance(x, int) then -- [LINE 707]
        return ObjValue[self][(LObj(x) + 1)]; -- [LINE 708]
      end;
      error('Not support unknown type.'); -- [LINE 710]
    end;
    setfenv(__getitem__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
tuple = setup_basic_class(tuple);
str = (function(_M)--(str: LuaObject)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {LuaObject};
  scope.__name__ = 'str';
  function doload()
    function __init__(self, value)
      if is_pyobj(value) then -- [LINE 716]
        value = _OP__Str__(value); -- [LINE 717]
        value = LObj(value); -- [LINE 718]
      end;
      ObjValue[self] = value; -- [LINE 720]
    end;
    setfenv(__init__, _M);
    function __str__(self)
      return self; -- [LINE 723]
    end;
    setfenv(__str__, _M);
    function __repr__(self)
      return str(lua.concat("'", ObjValue[self], "'")); -- [LINE 726]
    end;
    setfenv(__repr__, _M);
    function __len__(self)
      return int(lua.len(ObjValue[self])); -- [LINE 729]
    end;
    setfenv(__len__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
str = setup_basic_class(str);
bool = (function(_M)--(bool: LuaObject)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {LuaObject};
  scope.__name__ = 'bool';
  function doload()
    function __new__(cls, value)
      if not inited then -- [LINE 735]
        local instance = object.__new__(cls); -- [LINE 736]
        ObjValue[instance] = value; -- [LINE 737]
        return instance; -- [LINE 738]
      end;
      if is_pyobj(value) then -- [LINE 740]
        value = _OP__Bool__(value); -- [LINE 741]
      else
        value = value and true or false; -- [LINE 744]
      end;
      if value == true then -- [LINE 746]
        return True; -- [LINE 747]
      elseif value == false then -- [LINE 748]
        return False; -- [LINE 749]
      elseif is_pyobj(value) and type(value) == bool then -- [LINE 750]
        return value; -- [LINE 751]
      end;
      error('__Bool__ are returned unknown value.'); -- [LINE 753]
    end;
    setfenv(__new__, _M);
    function __repr__(self)
      local value = ObjValue[self]; -- [LINE 756]
      if value == true then -- [LINE 757]
        return str('True'); -- [LINE 758]
      elseif value == false then -- [LINE 759]
        return str('False'); -- [LINE 760]
      end;
    end;
    setfenv(__repr__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
bool = setup_basic_class(bool);
int = (function(_M)--(int: LuaObject)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {LuaObject};
  scope.__name__ = 'int';
  function doload()
    function __add__(self, other)
      return int((ObjValue[self] + ObjValue[other])); -- [LINE 768]
    end;
    setfenv(__add__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
int = setup_basic_class(int);
dict = (function(_M)--(dict: LuaObject)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {LuaObject};
  scope.__name__ = 'dict';
  function doload()
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
dict = setup_basic_class(dict);
local function inital()
  local cls, cinit;
  for cls, cinit in pairs(InitalBuiltinTypes) do -- [LINE 777]
    register_builtins_class(cls); -- [LINE 778]
    BuiltinTypes[cls] = true; -- [LINE 779]
  end;
  _M['NotImplemented'] = NotImplementedType(); -- [LINE 781]
  _M['Ellipsis'] = EllipsisType(); -- [LINE 782]
  _M['None'] = NoneType(); -- [LINE 783]
  _M['True'] = bool(true); -- [LINE 784]
  _M['False'] = bool(false); -- [LINE 785]
  return true; -- [LINE 787]
end;
inited = inital(); -- [LINE 789]
local x = list({int(1), int(2), int(3)}); -- [LINE 793]
local y = int(5); -- [LINE 794]
local z = int(7); -- [LINE 795]
print(x); -- [LINE 797]
print(True == nil); -- [LINE 798]
print(True); -- [LINE 799]
print(issubclass(int, object)); -- [LINE 800]
print(int.mro()); -- [LINE 801]
print(_OP__Add__(y, z)); -- [LINE 802]
print(UnstableException.mro()); -- [LINE 803]
error(UnstableException(str('Unstable World!'))); -- [LINE 804]
