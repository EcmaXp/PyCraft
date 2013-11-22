local _M = getfenv();
if pyscripter then -- [LINE 1]
  exit(__import__('pc').main()); -- [LINE 1]
end;
 -- [LINE 3]
lua = {}; -- [LINE 6]
lua.len = (function(obj) return #obj; end); -- [LINE 7]
lua.concat = (function(...) return table.concat({...}); end); -- [LINE 8]
lua.write = write or io.write; -- [LINE 9]
local key, value;
for key, value in pairs(_G) do -- [LINE 10]
  lua[key] = value; -- [LINE 11]
end;
local PY_OBJ_TAG = '#'; -- [LINE 13]
local LUA_OBJ_TAG = '@'; -- [LINE 14]
local TAG = '[PY]'; -- [LINE 16]
local ObjLastID = 0; -- [LINE 17]
local inited = False; -- [LINE 18]
local builtins = 'builtins'; -- [LINE 20]
local ObjID = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 23]
local ObjValue = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 24]
local ObjPCEX = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 25]
local Obj_FromID = setmetatable({}, {['__mode'] = 'v'}); -- [LINE 26]
local BuiltinTypes = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 27]
local builtin_methods = {'__new__', '__init__', '__del__', '__repr__', '__str__', '__bytes__', '__format__', '__lt__', '__le__', '__eq__', '__ne__', '__gt__', '__ge__', '__hash__', '__bool__', '__getattr__', '__getattribute__', '__setattr__', '__delattr__', '__dir__', '__get__', '__set__', '__delete__', '__slots__', '__call__', '__len__', '__getitem__', '__setitem__', '__delitem__', '__iter__', '__reversed__', '__contains__', '__add__', '__sub__', '__mul__', '__truediv__', '__floordiv__', '__mod__', '__divmod__', '__pow__', '__lshift__', '__rshift__', '__and__', '__xor__', '__or__', '__radd__', '__rsub__', '__rmul__', '__rtruediv__', '__rfloordiv__', '__rmod__', '__rdivmod__', '__rpow__', '__rlshift__', '__rrshift__', '__rand__', '__rxor__', '__ror__', '__iadd__', '__isub__', '__imul__', '__itruediv__', '__ifloordiv__', '__imod__', '__ipow__', '__ilshift__', '__irshift__', '__iand__', '__ixor__', '__ior__', '__neg__', '__pos__', '__abs__', '__invert__', '__complex__', '__int__', '__float__', '__round__', '__index__', '__enter__', '__exit__', '__lua__'}; -- [LINE 30]
local builtin_methods_rev = {}; -- [LINE 31]
local k, v;
for k, v in pairs(builtin_methods) do -- [LINE 32]
  builtin_methods_rev[v] = k; -- [LINE 33]
end;
assert(builtin_methods[42] == '__rshift__'); -- [LINE 35]
assert(builtin_methods_rev['__pos__'] == 72); -- [LINE 36]
local error = nil; -- [LINE 37]
local function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 40]
    error('This is not number', 2); -- [LINE 41]
  end;
  return math.floor(num) ~= num; -- [LINE 43]
end;
local function is_pyobj(obj)
  return ObjID[obj] ~= nil; -- [LINE 46]
end;
local function PObj(obj)
  if is_pyobj(obj) then -- [LINE 49]
    return obj; -- [LINE 50]
  else
    return LuaObject(obj); -- [LINE 52]
  end;
end;
local function LObj(obj)
  if is_pyobj(obj) then -- [LINE 55]
    return _OP__Lua__(obj); -- [LINE 56]
  else
    return obj; -- [LINE 58]
  end;
end;
local function require_pyobj(...)
  local objs = {...};
  local idx, obj;
  for idx, obj in pairs(objs) do -- [LINE 61]
    if not is_pyobj(obj) then -- [LINE 62]
      lua.print(lua.type(obj), obj); -- [LINE 63]
      error('Require python object.'); -- [LINE 64]
    end;
  end;
  return true; -- [LINE 66]
end;
local function register_pyobj(obj)
  ObjLastID = (ObjLastID + 1); -- [LINE 70]
  local obj_id = ObjLastID; -- [LINE 71]
  ObjID[obj] = obj_id; -- [LINE 73]
  Obj_FromID[obj_id] = obj; -- [LINE 74]
  return obj; -- [LINE 75]
end;
function error(msg, level)
  if level == nil then -- [LINE 78]
    level = 1; -- [LINE 79]
  end;
  if is_pyobj(msg) then -- [LINE 81]
    msg = LObj(msg); -- [LINE 82]
  end;
  level = (level + 1); -- [LINE 84]
  lua.error(lua.concat(TAG, ' ', tostring(msg)), level); -- [LINE 85]
end;
local function require_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 88]
    if value == nil then -- [LINE 89]
      error('SystemError: Not Enough Item'); -- [LINE 90]
    end;
  end;
  return True; -- [LINE 92]
end;
local function nonrequire_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 95]
    if value ~= nil then -- [LINE 96]
      error('SystemError: Not Enough Item'); -- [LINE 97]
    end;
  end;
  return True; -- [LINE 99]
end;
function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 102]
    error('This is not number', 2); -- [LINE 103]
  end;
  return math.floor(num) ~= num; -- [LINE 105]
end;
local function setup_base_class(cls)
  local pcex = {}; -- [LINE 108]
  local k, v;
  for k, v in pairs(cls) do -- [LINE 109]
    local idx = builtin_methods_rev[k]; -- [LINE 110]
    if idx ~= nil then -- [LINE 111]
      pcex[idx] = v; -- [LINE 112]
    end;
  end;
  ObjPCEX[cls] = pcex; -- [LINE 114]
  BuiltinTypes[cls] = false; -- [LINE 115]
  register_pyobj(cls); -- [LINE 116]
  return cls; -- [LINE 118]
end;
local function setup_basic_class(cls)
  setup_base_class(cls); -- [LINE 121]
  setmetatable(cls, type); -- [LINE 122]
  return cls; -- [LINE 124]
end;
local function setup_hide_class(cls)
  BuiltinTypes[cls] = nil; -- [LINE 127]
  return cls; -- [LINE 128]
end;
local function register_builtins_class(cls)
  local idx = 1; -- [LINE 131]
  local mro = {}; -- [LINE 132]
  mro[idx] = cls; -- [LINE 134]
  idx = (idx + 1); -- [LINE 135]
  local bases = rawget(cls, '__bases__'); -- [LINE 137]
  if bases ~= nil then -- [LINE 138]
    for i = #bases, 1, -1 do --; -- [LINE 139]
    if true then -- [LINE 140]
      local base = bases[i]; -- [LINE 141]
      if BuiltinTypes[base] ~= nil then -- [LINE 142]
        mro[idx] = base; -- [LINE 143]
        idx = (idx + 1); -- [LINE 144]
      end;
    end;
    end; -- [LINE 145]
  end;
  if cls ~= object then -- [LINE 147]
    mro[idx] = object; -- [LINE 148]
    idx = (idx + 1); -- [LINE 149]
  end;
  rawset(cls, '__bases__', nil); -- [LINE 151]
  rawset(cls, '__name__', str(rawget(cls, '__name__'))); -- [LINE 152]
  rawset(cls, '__module__', str('builtins')); -- [LINE 153]
  rawset(cls, '__mro__', tuple(mro)); -- [LINE 154]
  BuiltinTypes[cls] = true; -- [LINE 156]
  return cls; -- [LINE 157]
end;
local function Fail_OP(a, ax)
  error(lua.concat(LObj(repr(a)), ' are not support ', builtin_methods[ax])); -- [LINE 160]
end;
local function Fail_OP_Raw(a, raw_ax)
  error(lua.concat(LObj(repr(a)), ' are not support ', raw_ax)); -- [LINE 163]
end;
local function Fail_OP_Math_Raw(a, b, raw_ax)
  error(lua.concat('Not support ', LObj(repr(a)), ' ', raw_ax, ' ', LObj(repr(b)))); -- [LINE 166]
end;
local function Fail_OP_Math(a, b, ax, extra)
  if extra == nil then -- [LINE 169]
    extra = ''; -- [LINE 170]
  else
    extra = lua.concat(' ', extra); -- [LINE 172]
  end;
  error(lua.concat('Not support ', LObj(repr(a)), ' ', builtin_methods[ax], ' ', LObj(repr(b)), extra)); -- [LINE 174]
end;
local function Fail_OP_Math_Pow(a, b, ax, c)
  local extra = ''; -- [LINE 177]
  if c then -- [LINE 178]
    extra = lua.concat('% ', LObj(repr(c))); -- [LINE 179]
  end;
  Fail_OP_Math(a, b, ax, c); -- [LINE 181]
end;
local function OP_Call(ax)
  local function func(a, ...)
    local args = {...};
    assert(require_pyobj(a)); -- [LINE 185]
    local f = ObjPCEX[getmetatable(a)][ax]; -- [LINE 186]
    if f then -- [LINE 187]
      return f(a, ...); -- [LINE 188]
    end;
    Fail_OP(a, ax); -- [LINE 190]
  end;
  return func; -- [LINE 191]
end;
local function OP_Math2(ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 195]
    local am = ObjPCEX[getmetatable(a)]; -- [LINE 196]
    local bm = ObjPCEX[getmetatable(b)]; -- [LINE 197]
    local f = am[ax]; -- [LINE 199]
    if f then -- [LINE 200]
      local ret = f(a, b); -- [LINE 201]
      if ret ~= NotImplemented then -- [LINE 202]
        return ret; -- [LINE 202]
      end;
    end;
    f = bm[bx]; -- [LINE 204]
    if f then -- [LINE 205]
      ret = f(b, a); -- [LINE 206]
      if ret ~= NotImplemented then -- [LINE 207]
        return ret; -- [LINE 207]
      end;
    end;
    Fail_OP_Math(a, b, ax); -- [LINE 209]
  end;
  return func; -- [LINE 211]
end;
local function OP_Math3(cx, ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 215]
    local am = ObjPCEX[getmetatable(a)]; -- [LINE 216]
    local bm = ObjPCEX[getmetatable(b)]; -- [LINE 217]
    local is_n = isinstance(a, int) == True or isinstance(b, float) == True; -- [LINE 218]
    if is_n then -- [LINE 220]
      local f = am[ax]; -- [LINE 221]
      if f then -- [LINE 222]
        local ret = f(a, b); -- [LINE 223]
        if ret ~= NotImplemented then -- [LINE 224]
          return ret; -- [LINE 224]
        end;
      end;
    end;
    f = am[cx]; -- [LINE 226]
    if f then -- [LINE 227]
      ret = f(a, b); -- [LINE 228]
      if ret ~= NotImplemented then -- [LINE 229]
        return ret; -- [LINE 229]
      end;
    end;
    if not is_n then -- [LINE 232]
      f = am[ax]; -- [LINE 233]
      if f then -- [LINE 234]
        ret = f(a, b); -- [LINE 235]
        if ret ~= NotImplemented then -- [LINE 236]
          return ret; -- [LINE 236]
        end;
      end;
    end;
    f = bm[bx]; -- [LINE 238]
    if f then -- [LINE 239]
      ret = f(b, a); -- [LINE 240]
      if ret ~= NotImplemented then -- [LINE 241]
        return ret; -- [LINE 241]
      end;
    end;
    Fail_OP_Math(a, b, cx); -- [LINE 243]
  end;
  return func; -- [LINE 245]
end;
local function OP_Math2_Pow(ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 249]
    assert(require_pyobj(c) or c == nil); -- [LINE 250]
    local am = ObjPCEX[getmetatable(a)]; -- [LINE 251]
    local bm = ObjPCEX[getmetatable(b)]; -- [LINE 252]
    local f = am[ax]; -- [LINE 254]
    if f then -- [LINE 255]
      local ret = f(a, b, c); -- [LINE 256]
      if ret ~= NotImplemented then -- [LINE 257]
        return ret; -- [LINE 257]
      end;
    end;
    if c ~= nil then -- [LINE 259]
      f = bm[bx]; -- [LINE 264]
      if f then -- [LINE 265]
        ret = f(b, a); -- [LINE 266]
        if ret ~= NotImplemented then -- [LINE 267]
          return ret; -- [LINE 267]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 269]
  end;
  return func; -- [LINE 271]
end;
local function OP_Math3_Pow(cx, ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 275]
    assert(require_pyobj(c) or c == nil); -- [LINE 276]
    local am = ObjPCEX[getmetatable(a)]; -- [LINE 277]
    local bm = ObjPCEX[getmetatable(b)]; -- [LINE 278]
    local f = am[cx]; -- [LINE 280]
    if f then -- [LINE 281]
      local ret = f(a, b, c); -- [LINE 282]
      if ret ~= NotImplemented then -- [LINE 283]
        return ret; -- [LINE 283]
      end;
    end;
    f = am[ax]; -- [LINE 285]
    if f then -- [LINE 286]
      ret = f(a, b, c); -- [LINE 287]
      if ret ~= NotImplemented then -- [LINE 288]
        return ret; -- [LINE 288]
      end;
    end;
    if c ~= nil then -- [LINE 290]
      f = bm[bx]; -- [LINE 291]
      if f then -- [LINE 292]
        ret = f(b, a); -- [LINE 293]
        if ret ~= NotImplemented then -- [LINE 294]
          return ret; -- [LINE 294]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 296]
  end;
  return func; -- [LINE 298]
end;
function _OP__Is__(a, b)
  require_pyobj(a, b); -- [LINE 302]
  return ObjID[a] == ObjID[b]; -- [LINE 303]
end;
function _OP__IsNot__(a, b)
  return not _OP__Is__(a, b); -- [LINE 306]
end;
local function _(name)
  return builtin_methods_rev[name]; -- [LINE 308]
end;
 -- [LINE 309]
_OP__New__ = OP_Call(_('__new__')); -- [LINE 311]
_OP__Init__ = OP_Call(_('__init__')); -- [LINE 312]
_OP__Del__ = OP_Call(_('__del__')); -- [LINE 313]
_OP__Repr__ = OP_Call(_('__repr__')); -- [LINE 314]
_OP__Str__ = OP_Call(_('__str__')); -- [LINE 315]
_OP__Bytes__ = OP_Call(_('__bytes__')); -- [LINE 316]
_OP__Format__ = OP_Call(_('__format__')); -- [LINE 317]
_OP__Lt__ = OP_Call(_('__lt__')); -- [LINE 318]
_OP__Le__ = OP_Call(_('__le__')); -- [LINE 319]
_OP__Eq__ = OP_Call(_('__eq__')); -- [LINE 320]
_OP__Ne__ = OP_Call(_('__ne__')); -- [LINE 321]
_OP__Gt__ = OP_Call(_('__gt__')); -- [LINE 322]
_OP__Ge__ = OP_Call(_('__ge__')); -- [LINE 323]
_OP__Hash__ = OP_Call(_('__hash__')); -- [LINE 324]
_OP__Bool__ = OP_Call(_('__bool__')); -- [LINE 325]
_OP__Getattr__ = OP_Call(_('__getattr__')); -- [LINE 326]
_OP__Getattribute__ = OP_Call(_('__getattribute__')); -- [LINE 327]
_OP__Setattr__ = OP_Call(_('__setattr__')); -- [LINE 328]
_OP__Delattr__ = OP_Call(_('__delattr__')); -- [LINE 329]
_OP__Dir__ = OP_Call(_('__dir__')); -- [LINE 330]
_OP__Get__ = OP_Call(_('__get__')); -- [LINE 331]
_OP__Set__ = OP_Call(_('__set__')); -- [LINE 332]
_OP__Delete__ = OP_Call(_('__delete__')); -- [LINE 333]
_OP__Slots__ = OP_Call(_('__slots__')); -- [LINE 334]
_OP__Call__ = OP_Call(_('__call__')); -- [LINE 335]
_OP__Len__ = OP_Call(_('__len__')); -- [LINE 336]
_OP__Getitem__ = OP_Call(_('__getitem__')); -- [LINE 337]
_OP__Setitem__ = OP_Call(_('__setitem__')); -- [LINE 338]
_OP__Delitem__ = OP_Call(_('__delitem__')); -- [LINE 339]
_OP__Iter__ = OP_Call(_('__iter__')); -- [LINE 340]
_OP__Reversed__ = OP_Call(_('__reversed__')); -- [LINE 341]
_OP__Contains__ = OP_Call(_('__contains__')); -- [LINE 342]
_OP__Add__ = OP_Math2(_('__add__'), _('__radd__')); -- [LINE 345]
_OP__Sub__ = OP_Math2(_('__sub__'), _('__rsub__')); -- [LINE 346]
_OP__Mul__ = OP_Math2(_('__mul__'), _('__rmul__')); -- [LINE 347]
_OP__Truediv__ = OP_Math2(_('__truediv__'), _('__rtruediv__')); -- [LINE 348]
_OP__Floordiv__ = OP_Math2(_('__floordiv__'), _('__rfloordiv__')); -- [LINE 349]
_OP__Mod__ = OP_Math2(_('__mod__'), _('__rmod__')); -- [LINE 350]
_OP__Divmod__ = OP_Math2(_('__divmod__'), _('__rdivmod__')); -- [LINE 351]
_OP__Pow__ = OP_Math2_Pow(_('__pow__'), _('__rpow__')); -- [LINE 352]
_OP__Lshift__ = OP_Math2(_('__lshift__'), _('__rlshift__')); -- [LINE 353]
_OP__Rshift__ = OP_Math2(_('__rshift__'), _('__rrshift__')); -- [LINE 354]
_OP__And__ = OP_Math2(_('__and__'), _('__rand__')); -- [LINE 355]
_OP__Xor__ = OP_Math2(_('__xor__'), _('__rxor__')); -- [LINE 356]
_OP__Or__ = OP_Math2(_('__or__'), _('__ror__')); -- [LINE 357]
_OP__Iadd__ = OP_Math3(_('__iadd__'), _('__add__'), _('__radd__')); -- [LINE 360]
_OP__Isub__ = OP_Math3(_('__isub__'), _('__sub__'), _('__rsub__')); -- [LINE 361]
_OP__Imul__ = OP_Math3(_('__imul__'), _('__mul__'), _('__rmul__')); -- [LINE 362]
_OP__Itruediv__ = OP_Math3(_('__itruediv__'), _('__truediv__'), _('__rtruediv__')); -- [LINE 363]
_OP__Ifloordiv__ = OP_Math3(_('__ifloordiv__'), _('__floordiv__'), _('__rfloordiv__')); -- [LINE 364]
_OP__Imod__ = OP_Math3(_('__imod__'), _('__mod__'), _('__rmod__')); -- [LINE 365]
_OP__Ipow__ = OP_Math3_Pow(_('__ipow__'), _('__pow__'), _('__rpow__')); -- [LINE 366]
_OP__Ilshift__ = OP_Math3(_('__ilshift__'), _('__lshift__'), _('__rlshift__')); -- [LINE 367]
_OP__Irshift__ = OP_Math3(_('__irshift__'), _('__rshift__'), _('__rrshift__')); -- [LINE 368]
_OP__Iand__ = OP_Math3(_('__iand__'), _('__and__'), _('__rand__')); -- [LINE 369]
_OP__Ixor__ = OP_Math3(_('__ixor__'), _('__xor__'), _('__rxor__')); -- [LINE 370]
_OP__Ior__ = OP_Math3(_('__ior__'), _('__or__'), _('__ror__')); -- [LINE 371]
_OP__Neg__ = OP_Call(_('__neg__')); -- [LINE 374]
_OP__Pos__ = OP_Call(_('__pos__')); -- [LINE 375]
_OP__Abs__ = OP_Call(_('__abs__')); -- [LINE 376]
_OP__Invert__ = OP_Call(_('__invert__')); -- [LINE 377]
_OP__Complex__ = OP_Call(_('__complex__')); -- [LINE 378]
_OP__Int__ = OP_Call(_('__int__')); -- [LINE 379]
_OP__Float__ = OP_Call(_('__float__')); -- [LINE 380]
_OP__Round__ = OP_Call(_('__round__')); -- [LINE 381]
_OP__Index__ = OP_Call(_('__index__')); -- [LINE 382]
_OP__Enter__ = OP_Call(_('__enter__')); -- [LINE 383]
_OP__Exit__ = OP_Call(_('__exit__')); -- [LINE 384]
_OP__Lua__ = OP_Call(_('__lua__')); -- [LINE 387]
function repr(obj)
  if is_pyobj(obj) then -- [LINE 391]
    return _OP__Repr__(obj); -- [LINE 392]
  else
    return lua.concat(LUA_OBJ_TAG, '(', tostring(obj), ')'); -- [LINE 394]
  end;
end;
function print(...)
  local args = {...};
  local arr = {}; -- [LINE 397]
  local idx = 1; -- [LINE 398]
  local _, arg;
  for _, arg in pairs(args) do -- [LINE 400]
    if is_pyobj(arg) then -- [LINE 401]
      arg = str(arg); -- [LINE 402]
    else
      arg = repr(arg); -- [LINE 404]
    end;
    arg = LObj(arg); -- [LINE 406]
    arr[idx] = arg; -- [LINE 408]
    idx = (idx + 1); -- [LINE 409]
  end;
  local data = table.concat(arr, ' '); -- [LINE 411]
  data = lua.concat(data, '\n'); -- [LINE 412]
  lua.write(data); -- [LINE 413]
end;
function isinstance(obj, targets)
  require_pyobj(obj); -- [LINE 416]
  local cls = type(obj); -- [LINE 418]
  local mro = cls.mro(); -- [LINE 419]
  assert(type(mro) == list); -- [LINE 420]
  local _, supercls;
  for _, supercls in pairs(ObjValue[mro]) do -- [LINE 422]
    require_pyobj(supercls); -- [LINE 423]
    if supercls == targets then -- [LINE 424]
      return True; -- [LINE 425]
    end;
  end;
  return False; -- [LINE 427]
end;
function issubclass(cls, targets)
  require_pyobj(obj); -- [LINE 430]
  if type(cls) ~= type then -- [LINE 432]
    error('issubclass() arg 1 must be a class'); -- [LINE 433]
  end;
  local mro = cls.mro(); -- [LINE 435]
  assert(type(mro) == list); -- [LINE 436]
  local _, supercls;
  for _, supercls in pairs(ObjValue[mro]) do -- [LINE 438]
    require_pyobj(supercls); -- [LINE 439]
    if supercls == targets then -- [LINE 440]
      return True; -- [LINE 441]
    end;
  end;
  return False; -- [LINE 443]
end;
function id(obj)
  if is_pyobj(obj) then -- [LINE 446]
    return int(ObjID[obj]); -- [LINE 447]
  end;
  Fail_OP_Raw(obj, '__id!'); -- [LINE 449]
end;
function len(obj)
  return _OP__Len__(obj); -- [LINE 452]
end;
 -- [LINE 454]
_ = nil; -- [LINE 455]
object = (function(_G) -- (class object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  __name__ = 'object';
  function __init__(self)
  end;
  setfenv(__init__, _G);
  function __call(self, ...)
    local args = {...};
    return _OP__Call__(self, ...); -- [LINE 465]
  end;
  setfenv(__call, _G);
  function __index(self, key)
    return _OP__Getattribute__(self, key); -- [LINE 468]
  end;
  setfenv(__index, _G);
  function __newindex(self, key, value)
    return _OP__Setattr__(self, key, value); -- [LINE 471]
  end;
  setfenv(__newindex, _G);
  function __tostring(self)
    return lua.concat(PY_OBJ_TAG, '(', LObj(repr(self)), ')'); -- [LINE 474]
  end;
  setfenv(__tostring, _G);
  function __new__(cls, ...)
    local args = {...};
    local instance = {}; -- [LINE 477]
    instance = register_pyobj(instance); -- [LINE 478]
    lua.setmetatable(instance, cls); -- [LINE 479]
    _OP__Init__(instance, ...); -- [LINE 480]
    return instance; -- [LINE 482]
  end;
  setfenv(__new__, _G);
  function __getattribute__(self, k)
    local v = rawget(self, k); -- [LINE 485]
    if v ~= nil then -- [LINE 486]
      return v; -- [LINE 487]
    end;
    local mt = getmetatable(self); -- [LINE 489]
    v = rawget(mt, k); -- [LINE 490]
    if v ~= nil then -- [LINE 491]
      if lua.type(v) == 'function' then -- [LINE 492]
        return (function(...) return v(self, unpack({...})); end); -- [LINE 493]
      else
        return v; -- [LINE 495]
      end;
    end;
    error(lua.concat("Not found '", k, "' attribute.")); -- [LINE 497]
  end;
  setfenv(__getattribute__, _G);
  function __setattr__(self, key, value)
    if BuiltinTypes[type(self)] and inited then -- [LINE 500]
      error("TypeError: can't set attributes of built-in/extension type 'object'"); -- [LINE 501]
    end;
    rawset(self, key, value); -- [LINE 504]
  end;
  setfenv(__setattr__, _G);
  function __str__(self)
    return _OP__Repr__(self); -- [LINE 507]
  end;
  setfenv(__str__, _G);
  function __repr__(self)
    local mtable = getmetatable(self); -- [LINE 510]
    return str(lua.concat('<object ', LObj(mtable.__name__), ' at ', LObj(id(self)), '>')); -- [LINE 511]
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
    local instance = cls.__new__(cls, ...); -- [LINE 517]
    register_pyobj(instance); -- [LINE 518]
    return instance; -- [LINE 520]
  end;
  setfenv(__call__, _G);
  function __repr__(cls)
    return str(lua.concat("<class '", LObj(cls.__name__), "'>")); -- [LINE 523]
  end;
  setfenv(__repr__, _G);
  function mro(cls)
    return list(ObjValue[cls.__mro__]); -- [LINE 526]
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
    if lua.len(args) == 1 then -- [LINE 531]
      require_pyobj(args[1]); -- [LINE 532]
      return getmetatable(args[1]); -- [LINE 533]
    elseif lua.len(args) == 3 then -- [LINE 534]
    else
      error('Unexcepted arguments.'); -- [LINE 537]
    end;
  end;
  setfenv(__call__, _G);
  return getfenv();
end)(getfenv());
ptype = setup_base_class(ptype);
setmetatable(object, type); -- [LINE 539]
setmetatable(type, ptype); -- [LINE 540]
setmetatable(ptype, ptype); -- [LINE 541]
local BaseException = (function(_G) -- (class BaseException:object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __bases__ = {object};
  __name__ = 'BaseException';
  args = nil; -- [LINE 547]
  function __new__(cls, ...)
    local args = {...};
    local param = tuple(args); -- [LINE 550]
    local instance = object.__new__(cls); -- [LINE 551]
    rawset(instance, 'args', param); -- [LINE 552]
    _OP__Init__(instance, param); -- [LINE 553]
    return instance; -- [LINE 554]
  end;
  setfenv(__new__, _G);
  function __str__(self)
    local length = LObj(len(self.args)); -- [LINE 557]
    if length == 0 then -- [LINE 558]
      return str(''); -- [LINE 559]
    elseif length == 1 then -- [LINE 560]
      return str(_OP__Getitem__(self.args, int(0))); -- [LINE 561]
    end;
  end;
  setfenv(__str__, _G);
  function __repr__(self)
    local excname = LObj(type(self).__name__); -- [LINE 564]
    return lua.concat(excname, repr(self.args)); -- [LINE 565]
  end;
  setfenv(__repr__, _G);
  function __lua__(self)
    local excname = LObj(type(self).__name__); -- [LINE 568]
    local value = str(self); -- [LINE 569]
    if LObj(len(value)) > 0 then -- [LINE 571]
      return lua.concat(excname, ': ', LObj(value)); -- [LINE 572]
    else
      return lua.concat(excname); -- [LINE 574]
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
local UnstableException = (function(_G) -- (class UnstableException:Exception, BaseException)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({BaseException, Exception}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __bases__ = {Exception, BaseException};
  __name__ = 'UnstableException';
  return getfenv();
end)(getfenv());
UnstableException = setup_basic_class(UnstableException);
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
    if not inited then -- [LINE 587]
      local instance = object.__new__(cls, ...); -- [LINE 588]
      _OP__Init__(instance, ...); -- [LINE 589]
      return instance; -- [LINE 590]
    end;
    return cls._get_singleton(); -- [LINE 592]
  end;
  setfenv(__new__, _G);
  function _get_singleton(cls)
    error('Not defined.'); -- [LINE 595]
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
    return NotImplemented; -- [LINE 600]
  end;
  setfenv(_get_singleton, _G);
  function __repr__(self)
    return str('NotImplemented'); -- [LINE 603]
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
    return Ellipsis; -- [LINE 608]
  end;
  setfenv(_get_singleton, _G);
  function __repr__(self)
    return str('Ellipsis'); -- [LINE 611]
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
    return None; -- [LINE 616]
  end;
  setfenv(_get_singleton, _G);
  function __repr__(self)
    return str('None'); -- [LINE 619]
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
  LuaObject = true; -- [LINE 625]
  function __init__(self, obj)
    local mtable = getmetatable(obj); -- [LINE 629]
    if mtable and rawget(mtable, 'LuaObject') then -- [LINE 630]
      obj = LObj(obj); -- [LINE 631]
    end;
    ObjValue[self] = obj; -- [LINE 633]
  end;
  setfenv(__init__, _G);
  function __str__(self)
    return str(_OP__Repr__(self)); -- [LINE 636]
  end;
  setfenv(__str__, _G);
  function __repr__(self)
    return str(tostring(ObjValue[self])); -- [LINE 639]
  end;
  setfenv(__repr__, _G);
  function __lua__(self)
    return ObjValue[self]; -- [LINE 642]
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
    if is_pyobj(value) then -- [LINE 648]
      self.check_type(value); -- [LINE 649]
    end;
    ObjValue[self] = value; -- [LINE 651]
  end;
  setfenv(__init__, _G);
  function check_type(self, value)
    if type(value) == 'table' then -- [LINE 654]
    elseif value[lua.len(value)] == nil then -- [LINE 655]
    elseif value[1] == nil then -- [LINE 656]
    elseif value[0] ~= nil then -- [LINE 657]
    else
      return true; -- [LINE 659]
    end;
    return false; -- [LINE 661]
  end;
  setfenv(check_type, _G);
  function make_repr(self, s, e)
    local ret = {}; -- [LINE 664]
    local idx = 1; -- [LINE 665]
    local sep = ''; -- [LINE 667]
    ret[idx] = s; -- [LINE 668]
    idx = (idx + 1); -- [LINE 668]
    local k, v;
    for k, v in pairs(ObjValue[self]) do -- [LINE 669]
      ret[idx] = sep; -- [LINE 670]
      idx = (idx + 1); -- [LINE 670]
      ret[idx] = LObj(repr(v)); -- [LINE 671]
      idx = (idx + 1); -- [LINE 671]
      sep = ', '; -- [LINE 672]
    end;
    ret[idx] = e; -- [LINE 674]
    idx = (idx + 1); -- [LINE 674]
    return table.concat(ret); -- [LINE 676]
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
    return self.make_repr('[', ']'); -- [LINE 682]
  end;
  setfenv(__repr__, _G);
  function __setattr__(self, key, value)
    error('Not allowed'); -- [LINE 685]
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
    return self.make_repr('(', ')'); -- [LINE 691]
  end;
  setfenv(__repr__, _G);
  function __setattr__(self, key, value)
    error('Not allowed'); -- [LINE 694]
  end;
  setfenv(__setattr__, _G);
  function __len__(self)
    return int(lua.len(ObjValue[self])); -- [LINE 697]
  end;
  setfenv(__len__, _G);
  function __getitem__(self, x)
    assert(is_pyobj(x)); -- [LINE 700]
    if isinstance(x, int) then -- [LINE 701]
      return ObjValue[self][(LObj(x) + 1)]; -- [LINE 702]
    end;
    error('Not support unknown type.'); -- [LINE 704]
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
    if is_pyobj(value) then -- [LINE 710]
      value = _OP__Str__(value); -- [LINE 711]
      value = LObj(value); -- [LINE 712]
    end;
    ObjValue[self] = value; -- [LINE 714]
  end;
  setfenv(__init__, _G);
  function __str__(self)
    return self; -- [LINE 717]
  end;
  setfenv(__str__, _G);
  function __repr__(self)
    return str(lua.concat("'", ObjValue[self], "'")); -- [LINE 720]
  end;
  setfenv(__repr__, _G);
  function __len__(self)
    return int(lua.len(ObjValue[self])); -- [LINE 723]
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
    if not inited then -- [LINE 729]
      local instance = object.__new__(cls); -- [LINE 730]
      ObjValue[instance] = value; -- [LINE 731]
      return instance; -- [LINE 732]
    end;
    if is_pyobj(value) then -- [LINE 734]
      value = _OP__Bool__(value); -- [LINE 735]
    else
      value = value and true or false; -- [LINE 738]
    end;
    if value == true then -- [LINE 740]
      return True; -- [LINE 741]
    elseif value == false then -- [LINE 742]
      return False; -- [LINE 743]
    elseif is_pyobj(value) and type(value) == bool then -- [LINE 744]
      return value; -- [LINE 745]
    end;
    error('__Bool__ are returned unknown value.'); -- [LINE 747]
  end;
  setfenv(__new__, _G);
  function __repr__(self)
    local value = ObjValue[self]; -- [LINE 750]
    if value == true then -- [LINE 751]
      return str('True'); -- [LINE 752]
    elseif value == false then -- [LINE 753]
      return str('False'); -- [LINE 754]
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
    return int((ObjValue[self] + ObjValue[other])); -- [LINE 762]
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
  local cls, inited;
  for cls, inited in pairs(BuiltinTypes) do -- [LINE 771]
    assert(inited == false); -- [LINE 772]
    register_builtins_class(cls); -- [LINE 773]
    inited = BuiltinTypes[cls]; -- [LINE 774]
    assert(inited == true); -- [LINE 775]
  end;
  _M['NotImplemented'] = NotImplementedType(); -- [LINE 777]
  _M['Ellipsis'] = EllipsisType(); -- [LINE 778]
  _M['None'] = NoneType(); -- [LINE 779]
  _M['True'] = bool(true); -- [LINE 780]
  _M['False'] = bool(false); -- [LINE 781]
  return true; -- [LINE 783]
end;
inited = inital(); -- [LINE 785]
local x = list({int(1), int(2), int(3)}); -- [LINE 789]
local y = int(5); -- [LINE 790]
local z = int(7); -- [LINE 791]
print(x); -- [LINE 793]
print(True == nil); -- [LINE 794]
print(True); -- [LINE 795]
print(issubclass(int, object)); -- [LINE 796]
print(int.mro()); -- [LINE 797]
print(_OP__Add__(y, z)); -- [LINE 798]
print(UnstableException.mro()); -- [LINE 799]
error(UnstableException(str('Unstable World!'))); -- [LINE 800]
