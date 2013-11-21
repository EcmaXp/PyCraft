local _M = getfenv();
if pyscripter then -- [LINE 1]
  exit(__import__('pc').main()); -- [LINE 1]
end;
local __PC_METHODS = {'__new__', '__init__', '__del__', '__repr__', '__str__', '__bytes__', '__format__', '__lt__', '__le__', '__eq__', '__ne__', '__gt__', '__ge__', '__hash__', '__bool__', '__getattr__', '__getattribute__', '__setattr__', '__delattr__', '__dir__', '__get__', '__set__', '__delete__', '__slots__', '__call__', '__len__', '__getitem__', '__setitem__', '__delitem__', '__iter__', '__reversed__', '__contains__', '__add__', '__sub__', '__mul__', '__truediv__', '__floordiv__', '__mod__', '__divmod__', '__pow__', '__lshift__', '__rshift__', '__and__', '__xor__', '__or__', '__radd__', '__rsub__', '__rmul__', '__rtruediv__', '__rfloordiv__', '__rmod__', '__rdivmod__', '__rpow__', '__rlshift__', '__rrshift__', '__rand__', '__rxor__', '__ror__', '__iadd__', '__isub__', '__imul__', '__itruediv__', '__ifloordiv__', '__imod__', '__ipow__', '__ilshift__', '__irshift__', '__iand__', '__ixor__', '__ior__', '__neg__', '__pos__', '__abs__', '__invert__', '__complex__', '__int__', '__float__', '__round__', '__index__', '__enter__', '__exit__', '__lua__'}; -- [LINE 3]
local __PC_METHODS_REV = {}; -- [LINE 3]
local k, v;
for k, v in pairs(__PC_METHODS) do -- [LINE 3]
  __PC_METHODS_REV[v] = k; -- [LINE 3]
end;
local function DO_SUPPORT_PCEX(cls)
  cls.__PCEX__ = nil; -- [LINE 3]
  local pcex = {}; -- [LINE 3]
  local k, v;
  for k, v in pairs(cls) do -- [LINE 3]
    local idx = __PC_METHODS_REV[k]; -- [LINE 3]
    if idx ~= nil then -- [LINE 3]
      pcex[idx] = v; -- [LINE 3]
    end;
  end;
  cls.__PCEX__ = pcex; -- [LINE 3]
  return cls; -- [LINE 3]
end;
 -- [LINE 3]
 -- [LINE 4]
local TAG = '[PY]'; -- [LINE 7]
lua = {}; -- [LINE 8]
local key, value;
for key, value in pairs(_G) do -- [LINE 9]
  lua[key] = value; -- [LINE 10]
end;
local builtins = 'builtins'; -- [LINE 12]
local OBJ_ID = 0; -- [LINE 13]
local inited = False; -- [LINE 14]
local ObjID = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 17]
local ObjValue = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 18]
local Obj_FromID = setmetatable({}, {['__mode'] = 'v'}); -- [LINE 19]
local IsBuiltinTypes = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 20]
local __PCEX__ = '__PCEX__'; -- [LINE 23]
local methods = {'__new__', '__init__', '__del__', '__repr__', '__str__', '__bytes__', '__format__', '__lt__', '__le__', '__eq__', '__ne__', '__gt__', '__ge__', '__hash__', '__bool__', '__getattr__', '__getattribute__', '__setattr__', '__delattr__', '__dir__', '__get__', '__set__', '__delete__', '__slots__', '__call__', '__len__', '__getitem__', '__setitem__', '__delitem__', '__iter__', '__reversed__', '__contains__', '__add__', '__sub__', '__mul__', '__truediv__', '__floordiv__', '__mod__', '__divmod__', '__pow__', '__lshift__', '__rshift__', '__and__', '__xor__', '__or__', '__radd__', '__rsub__', '__rmul__', '__rtruediv__', '__rfloordiv__', '__rmod__', '__rdivmod__', '__rpow__', '__rlshift__', '__rrshift__', '__rand__', '__rxor__', '__ror__', '__iadd__', '__isub__', '__imul__', '__itruediv__', '__ifloordiv__', '__imod__', '__ipow__', '__ilshift__', '__irshift__', '__iand__', '__ixor__', '__ior__', '__neg__', '__pos__', '__abs__', '__invert__', '__complex__', '__int__', '__float__', '__round__', '__index__', '__enter__', '__exit__', '__lua__'}; -- [LINE 24]
local function lua_len(obj)
  return #obj; -- [LINE 27]
end;
local function lua_concat(...)
  local args = {...};
  local r = ''; -- [LINE 30]
  local _, x;
  for _, x in pairs(args) do -- [LINE 31]
    x = tostring(x); -- [LINE 32]
    r = r..x; -- [LINE 33]
  end;
  return r; -- [LINE 35]
end;
lua.len = lua_len; -- [LINE 37]
lua.concat = lua_concat; -- [LINE 38]
local function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 41]
    error('This is not number', 2); -- [LINE 42]
  end;
  return math.floor(num) ~= num; -- [LINE 44]
end;
local function error(msg, level)
  if level == nil then -- [LINE 47]
    level = 1; -- [LINE 48]
  end;
  level = (level + 1); -- [LINE 50]
  lua.error(lua.concat(TAG, ' ', msg), level); -- [LINE 51]
end;
local function require_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 54]
    if value == nil then -- [LINE 55]
      error('SystemError: Not Enough Item'); -- [LINE 56]
    end;
  end;
  return True; -- [LINE 58]
end;
local function nonrequire_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 61]
    if value ~= nil then -- [LINE 62]
      error('SystemError: Not Enough Item'); -- [LINE 63]
    end;
  end;
  return True; -- [LINE 65]
end;
function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 68]
    error('This is not number', 2); -- [LINE 69]
  end;
  return math.floor(num) ~= num; -- [LINE 71]
end;
local function is_pyobj(obj)
  return ObjID[obj] ~= nil; -- [LINE 74]
end;
local function to_pyobj(obj)
  if is_pyobj(obj) then -- [LINE 77]
    return obj; -- [LINE 78]
  else
    return LuaObject(obj); -- [LINE 80]
  end;
end;
local function to_luaobj(obj)
  if is_pyobj(obj) then -- [LINE 94]
    return _OP__Lua__(obj); -- [LINE 95]
  else
    return obj; -- [LINE 97]
  end;
end;
local function require_pyobj(...)
  local objs = {...};
  local idx, obj;
  for idx, obj in pairs(objs) do -- [LINE 100]
    if not is_pyobj(obj) then -- [LINE 101]
      lua.print(lua.type(obj), obj); -- [LINE 102]
      error('Require python object.'); -- [LINE 103]
    end;
  end;
  return true; -- [LINE 105]
end;
local function register_pyobj(obj)
  OBJ_ID = (OBJ_ID + 1); -- [LINE 109]
  local obj_id = OBJ_ID; -- [LINE 110]
  ObjID[obj] = obj_id; -- [LINE 112]
  Obj_FromID[obj_id] = obj; -- [LINE 113]
  return obj; -- [LINE 114]
end;
local function register_builtins_class(cls, ...)
  local bases = {...};
  local mro = {}; -- [LINE 117]
  local idx = 1; -- [LINE 118]
  for i = #bases, 1, -1 do --; -- [LINE 119]
  if true then -- [LINE 120]
    local base = bases[i]; -- [LINE 121]
    mro[idx] = base; -- [LINE 122]
    idx = (idx + 1); -- [LINE 123]
  end;
  end; -- [LINE 124]
  mro[idx] = cls; -- [LINE 126]
  rawset(cls, '__module__', str('builtins')); -- [LINE 127]
  rawset(cls, '__mro__', tuple(mro)); -- [LINE 128]
  IsBuiltinTypes[cls] = true; -- [LINE 129]
  return cls; -- [LINE 130]
end;
local function Fail_OP(a, ax)
  error(lua.concat(to_luaobj(repr(a)), ' are not support ', methods[ax])); -- [LINE 133]
end;
local function Fail_OP_Raw(a, raw_ax)
  error(lua.concat(to_luaobj(repr(a)), ' are not support ', raw_ax)); -- [LINE 136]
end;
local function Fail_OP_Math_Raw(a, b, raw_ax)
  error(lua.concat('Not support ', to_luaobj(repr(a)), ' ', raw_ax, ' ', to_luaobj(repr(b)))); -- [LINE 139]
end;
local function Fail_OP_Math(a, b, ax, extra)
  if extra == nil then -- [LINE 142]
    extra = ''; -- [LINE 143]
  else
    extra = lua.concat(' ', extra); -- [LINE 145]
  end;
  error(lua.concat('Not support ', to_luaobj(repr(a)), ' ', methods[ax], ' ', to_luaobj(repr(b)), extra)); -- [LINE 147]
end;
local function Fail_OP_Math_Pow(a, b, ax, c)
  local extra = ''; -- [LINE 150]
  if c then -- [LINE 151]
    extra = lua.concat('% ', to_luaobj(repr(c))); -- [LINE 152]
  end;
  Fail_OP_Math(a, b, ax, c); -- [LINE 154]
end;
function repr(obj)
  if is_pyobj(obj) then -- [LINE 158]
    return _OP__Repr__(obj); -- [LINE 159]
  else
    return lua.concat('@(', tostring(obj), ')'); -- [LINE 161]
  end;
end;
function print(...)
  local args = {...};
  local write = lua.io.write; -- [LINE 165]
  local sep = ' '; -- [LINE 166]
  local _, arg;
  for _, arg in pairs(args) do -- [LINE 168]
    if is_pyobj(arg) then -- [LINE 169]
      arg = str(arg); -- [LINE 170]
    else
      arg = repr(arg); -- [LINE 172]
    end;
    arg = to_luaobj(arg); -- [LINE 174]
    write(arg); -- [LINE 175]
    write(sep); -- [LINE 176]
  end;
  write('\n'); -- [LINE 178]
end;
function isinstance(cls, targets)
  require_pyobj(obj); -- [LINE 182]
  if type(cls) ~= type then -- [LINE 184]
    cls = type(obj); -- [LINE 185]
  end;
  local mro = cls.mro(); -- [LINE 187]
  assert(type(mro) == tuple); -- [LINE 188]
  local _, supercls;
  for _, supercls in pairs(mro.value) do -- [LINE 190]
    require_pyobj(supercls); -- [LINE 191]
    if supercls == targets then -- [LINE 192]
      return True; -- [LINE 193]
    end;
  end;
  return False; -- [LINE 195]
end;
local function issubclass(cls, targets)
  require_pyobj(obj); -- [LINE 198]
  if type(cls) ~= type then -- [LINE 200]
    error('issubclass() arg 1 must be a class'); -- [LINE 201]
  end;
  local mro = cls.mro(); -- [LINE 203]
  assert(type(mro) == tuple); -- [LINE 204]
  local _, supercls;
  for _, supercls in pairs(ObjValue[mro]) do -- [LINE 206]
    require_pyobj(supercls); -- [LINE 207]
    if supercls == targets then -- [LINE 208]
      return True; -- [LINE 209]
    end;
  end;
  return False; -- [LINE 211]
end;
function id(obj)
  if is_pyobj(obj) then -- [LINE 215]
    return int(ObjID[obj]); -- [LINE 216]
  end;
  Fail_OP_Raw(obj, '__id__!'); -- [LINE 218]
end;
local function OP_Call(ax)
  local function func(a, ...)
    local args = {...};
    assert(require_pyobj(a)); -- [LINE 222]
    local f = rawget(getmetatable(a), __PCEX__)[ax]; -- [LINE 223]
    if f then -- [LINE 224]
      return f(a, ...); -- [LINE 225]
    end;
    Fail_OP(a, ax); -- [LINE 227]
  end;
  return func; -- [LINE 228]
end;
local function OP_Math2(ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 232]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 233]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 234]
    local f = am[ax]; -- [LINE 236]
    if f then -- [LINE 237]
      local ret = f(a, b); -- [LINE 238]
      if ret ~= NotImplemented then -- [LINE 239]
        return ret; -- [LINE 239]
      end;
    end;
    f = bm[bx]; -- [LINE 241]
    if f then -- [LINE 242]
      ret = f(b, a); -- [LINE 243]
      if ret ~= NotImplemented then -- [LINE 244]
        return ret; -- [LINE 244]
      end;
    end;
    Fail_OP_Math(a, b, ax); -- [LINE 246]
  end;
  return func; -- [LINE 248]
end;
local function OP_Math3(cx, ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 252]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 253]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 254]
    local f = am[cx]; -- [LINE 256]
    if f then -- [LINE 257]
      local ret = f(a, b); -- [LINE 258]
      if ret ~= NotImplemented then -- [LINE 259]
        return ret; -- [LINE 259]
      end;
    end;
    f = am[ax]; -- [LINE 262]
    if f then -- [LINE 263]
      ret = f(a, b); -- [LINE 264]
      if ret ~= NotImplemented then -- [LINE 265]
        return ret; -- [LINE 265]
      end;
    end;
    f = bm[bx]; -- [LINE 267]
    if f then -- [LINE 268]
      ret = f(b, a); -- [LINE 269]
      if ret ~= NotImplemented then -- [LINE 270]
        return ret; -- [LINE 270]
      end;
    end;
    Fail_OP_Math(a, b, cx); -- [LINE 272]
  end;
  return func; -- [LINE 274]
end;
local function OP_Math2_Pow(ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 278]
    assert(require_pyobj(c) or c == nil); -- [LINE 279]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 280]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 281]
    local f = am[ax]; -- [LINE 283]
    if f then -- [LINE 284]
      local ret = f(a, b, c); -- [LINE 285]
      if ret ~= NotImplemented then -- [LINE 286]
        return ret; -- [LINE 286]
      end;
    end;
    if c ~= nil then -- [LINE 288]
      f = bm[bx]; -- [LINE 293]
      if f then -- [LINE 294]
        ret = f(b, a); -- [LINE 295]
        if ret ~= NotImplemented then -- [LINE 296]
          return ret; -- [LINE 296]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 298]
  end;
  return func; -- [LINE 300]
end;
local function OP_Math3_Pow(cx, ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 304]
    assert(require_pyobj(c) or c == nil); -- [LINE 305]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 306]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 307]
    local f = am[cx]; -- [LINE 309]
    if f then -- [LINE 310]
      local ret = f(a, b, c); -- [LINE 311]
      if ret ~= NotImplemented then -- [LINE 312]
        return ret; -- [LINE 312]
      end;
    end;
    f = am[ax]; -- [LINE 314]
    if f then -- [LINE 315]
      ret = f(a, b, c); -- [LINE 316]
      if ret ~= NotImplemented then -- [LINE 317]
        return ret; -- [LINE 317]
      end;
    end;
    if c ~= nil then -- [LINE 319]
      f = bm[bx]; -- [LINE 320]
      if f then -- [LINE 321]
        ret = f(b, a); -- [LINE 322]
        if ret ~= NotImplemented then -- [LINE 323]
          return ret; -- [LINE 323]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 325]
  end;
  return func; -- [LINE 327]
end;
function _OP__Is__(a, b)
  require_pyobj(a, b); -- [LINE 331]
  return ObjID[a] == ObjID[b]; -- [LINE 332]
end;
function _OP__IsNot__(a, b)
  return not _OP__Is__(a, b); -- [LINE 335]
end;
 -- [LINE 337]
_OP__New__ = OP_Call(1); -- [LINE 339]
_OP__Init__ = OP_Call(2); -- [LINE 340]
_OP__Del__ = OP_Call(3); -- [LINE 341]
_OP__Repr__ = OP_Call(4); -- [LINE 342]
_OP__Str__ = OP_Call(5); -- [LINE 343]
_OP__Bytes__ = OP_Call(6); -- [LINE 344]
_OP__Format__ = OP_Call(7); -- [LINE 345]
_OP__Lt__ = OP_Call(8); -- [LINE 346]
_OP__Le__ = OP_Call(9); -- [LINE 347]
_OP__Eq__ = OP_Call(10); -- [LINE 348]
_OP__Ne__ = OP_Call(11); -- [LINE 349]
_OP__Gt__ = OP_Call(12); -- [LINE 350]
_OP__Ge__ = OP_Call(13); -- [LINE 351]
_OP__Hash__ = OP_Call(14); -- [LINE 352]
_OP__Bool__ = OP_Call(15); -- [LINE 353]
_OP__Getattr__ = OP_Call(16); -- [LINE 354]
_OP__Getattribute__ = OP_Call(17); -- [LINE 355]
_OP__Setattr__ = OP_Call(18); -- [LINE 356]
_OP__Delattr__ = OP_Call(19); -- [LINE 357]
_OP__Dir__ = OP_Call(20); -- [LINE 358]
_OP__Get__ = OP_Call(21); -- [LINE 359]
_OP__Set__ = OP_Call(22); -- [LINE 360]
_OP__Delete__ = OP_Call(23); -- [LINE 361]
_OP__Slots__ = OP_Call(24); -- [LINE 362]
_OP__Call__ = OP_Call(25); -- [LINE 363]
_OP__Len__ = OP_Call(26); -- [LINE 364]
_OP__Getitem__ = OP_Call(27); -- [LINE 365]
_OP__Setitem__ = OP_Call(28); -- [LINE 366]
_OP__Delitem__ = OP_Call(29); -- [LINE 367]
_OP__Iter__ = OP_Call(30); -- [LINE 368]
_OP__Reversed__ = OP_Call(31); -- [LINE 369]
_OP__Contains__ = OP_Call(32); -- [LINE 370]
_OP__Add__ = OP_Math2(33, 46); -- [LINE 373]
_OP__Sub__ = OP_Math2(34, 47); -- [LINE 374]
_OP__Mul__ = OP_Math2(35, 48); -- [LINE 375]
_OP__Truediv__ = OP_Math2(36, 49); -- [LINE 376]
_OP__Floordiv__ = OP_Math2(37, 50); -- [LINE 377]
_OP__Mod__ = OP_Math2(38, 51); -- [LINE 378]
_OP__Divmod__ = OP_Math2(39, 52); -- [LINE 379]
_OP__Pow__ = OP_Math2_Pow(40, 53); -- [LINE 380]
_OP__Lshift__ = OP_Math2(41, 54); -- [LINE 381]
_OP__Rshift__ = OP_Math2(42, 55); -- [LINE 382]
_OP__And__ = OP_Math2(43, 56); -- [LINE 383]
_OP__Xor__ = OP_Math2(44, 57); -- [LINE 384]
_OP__Or__ = OP_Math2(45, 58); -- [LINE 385]
_OP__Iadd__ = OP_Math3(59, 33, 46); -- [LINE 388]
_OP__Isub__ = OP_Math3(60, 34, 47); -- [LINE 389]
_OP__Imul__ = OP_Math3(61, 35, 48); -- [LINE 390]
_OP__Itruediv__ = OP_Math3(62, 36, 49); -- [LINE 391]
_OP__Ifloordiv__ = OP_Math3(63, 37, 50); -- [LINE 392]
_OP__Imod__ = OP_Math3(64, 38, 51); -- [LINE 393]
_OP__Ipow__ = OP_Math3_Pow(65, 40, 53); -- [LINE 394]
_OP__Ilshift__ = OP_Math3(66, 41, 54); -- [LINE 395]
_OP__Irshift__ = OP_Math3(67, 42, 55); -- [LINE 396]
_OP__Iand__ = OP_Math3(68, 43, 56); -- [LINE 397]
_OP__Ixor__ = OP_Math3(69, 44, 57); -- [LINE 398]
_OP__Ior__ = OP_Math3(70, 45, 58); -- [LINE 399]
_OP__Neg__ = OP_Call(71); -- [LINE 402]
_OP__Pos__ = OP_Call(72); -- [LINE 403]
_OP__Abs__ = OP_Call(73); -- [LINE 404]
_OP__Invert__ = OP_Call(74); -- [LINE 405]
_OP__Complex__ = OP_Call(75); -- [LINE 406]
_OP__Int__ = OP_Call(76); -- [LINE 407]
_OP__Float__ = OP_Call(77); -- [LINE 408]
_OP__Round__ = OP_Call(78); -- [LINE 409]
_OP__Index__ = OP_Call(79); -- [LINE 410]
_OP__Enter__ = OP_Call(80); -- [LINE 411]
_OP__Exit__ = OP_Call(81); -- [LINE 412]
_OP__Lua__ = OP_Call(82); -- [LINE 415]
 -- [LINE 416]
object = (function(_G) -- (class object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  __name__ = 'object';
  function __init__(self)
  end;
  setfenv(__init__, _G);
  function __call(self, ...)
    local args = {...};
    return _OP__Call__(self, ...); -- [LINE 425]
  end;
  setfenv(__call, _G);
  function __index(self, key)
    return _OP__Getattribute__(self, key); -- [LINE 428]
  end;
  setfenv(__index, _G);
  function __newindex(self, key, value)
    return _OP__Setattr__(self, key, value); -- [LINE 431]
  end;
  setfenv(__newindex, _G);
  function __tostring(self)
    return lua.concat('#(', to_luaobj(repr(self)), ')'); -- [LINE 434]
  end;
  setfenv(__tostring, _G);
  function __new__(cls, ...)
    local args = {...};
    local instance = register_pyobj({}); -- [LINE 437]
    lua.setmetatable(instance, cls); -- [LINE 438]
    _OP__Init__(instance, ...); -- [LINE 439]
    return instance; -- [LINE 441]
  end;
  setfenv(__new__, _G);
  function __getattribute__(self, k)
    local v = rawget(self, k); -- [LINE 444]
    if v ~= nil then -- [LINE 445]
      return v; -- [LINE 446]
    end;
    local mt = getmetatable(self); -- [LINE 448]
    v = rawget(mt, k); -- [LINE 449]
    if v ~= nil then -- [LINE 450]
      if lua.type(v) == 'function' then -- [LINE 451]
        return (function(...) return v(self, unpack({...})) end); -- [LINE 452]
      else
        return v; -- [LINE 454]
      end;
    end;
    error(lua.concat("Not found '", k, "' attribute.")); -- [LINE 456]
  end;
  setfenv(__getattribute__, _G);
  function __setattr__(self, key, value)
    if IsBuiltinTypes[type(self)] and inited then -- [LINE 459]
      error("TypeError: can't set attributes of built-in/extension type 'object'"); -- [LINE 460]
    end;
    rawset(self, key, value); -- [LINE 463]
  end;
  setfenv(__setattr__, _G);
  function __str__(self)
    return _OP__Repr__(self); -- [LINE 466]
  end;
  setfenv(__str__, _G);
  function __repr__(self)
    local mtable = getmetatable(self); -- [LINE 469]
    return str(concat('<object ', mtable.__name__, ' at ', tostring(self.__id), '>')); -- [LINE 470]
  end;
  setfenv(__repr__, _G);
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
object = register_pyobj(object);
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
    local instance = cls.__new__(cls, ...); -- [LINE 476]
    register_pyobj(instance); -- [LINE 477]
    return instance; -- [LINE 479]
  end;
  setfenv(__call__, _G);
  function __repr__(cls)
    return str(lua.concat("<class '", cls.__name__, "'>")); -- [LINE 482]
  end;
  setfenv(__repr__, _G);
  function mro(cls)
    return cls.__mro__; -- [LINE 485]
  end;
  setfenv(mro, _G);
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
type = register_pyobj(type);
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
    if lua.len(args) == 1 then -- [LINE 490]
      require_pyobj(args[1]); -- [LINE 491]
      return getmetatable(args[1]); -- [LINE 492]
    elseif lua.len(args) == 3 then -- [LINE 493]
    else
      error('Unexcepted arguments.'); -- [LINE 496]
    end;
  end;
  setfenv(__call__, _G);
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
ptype = register_pyobj(ptype);
setmetatable(object, type); -- [LINE 498]
setmetatable(type, ptype); -- [LINE 499]
setmetatable(ptype, ptype); -- [LINE 500]
local BaseException = (function(_G) -- (class BaseException:object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'BaseException';
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(BaseException, type);
BaseException = register_pyobj(BaseException);
local LuaObject = (function(_G) -- (class LuaObject:object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'LuaObject';
  LuaObject = true; -- [LINE 509]
  function __init__(self, obj)
    local mtable = getmetatable(obj); -- [LINE 513]
    if mtable and rawget(mtable, 'LuaObject') then -- [LINE 514]
      obj = to_luaobj(obj); -- [LINE 515]
    end;
    ObjValue[self] = obj; -- [LINE 517]
  end;
  setfenv(__init__, _G);
  function __str__(self)
    return str(_OP__Repr__(self)); -- [LINE 520]
  end;
  setfenv(__str__, _G);
  function __repr__(self)
    return str(tostring(ObjValue[self])); -- [LINE 523]
  end;
  setfenv(__repr__, _G);
  function __lua__(self)
    return ObjValue[self]; -- [LINE 526]
  end;
  setfenv(__lua__, _G);
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(LuaObject, type);
LuaObject = register_pyobj(LuaObject);
local LuaValueOnlySequance = (function(_G) -- (class LuaValueOnlySequance:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'LuaValueOnlySequance';
  function __init__(self, value)
    if is_pyobj(value) then -- [LINE 531]
      self.check_type(value); -- [LINE 532]
    end;
    ObjValue[self] = value; -- [LINE 534]
  end;
  setfenv(__init__, _G);
  function check_type(self, value)
    if type(value) == 'table' then -- [LINE 537]
    elseif value[lua.len(value)] == nil then -- [LINE 538]
    elseif value[1] == nil then -- [LINE 539]
    elseif value[0] ~= nil then -- [LINE 540]
    else
      return true; -- [LINE 542]
    end;
    return false; -- [LINE 544]
  end;
  setfenv(check_type, _G);
  function make_repr(self, s, e)
    local ret = {}; -- [LINE 547]
    local idx = 1; -- [LINE 548]
    local sep = ''; -- [LINE 550]
    ret[idx] = s; -- [LINE 551]
    idx = (idx + 1); -- [LINE 551]
    local k, v;
    for k, v in pairs(ObjValue[self]) do -- [LINE 552]
      ret[idx] = sep; -- [LINE 553]
      idx = (idx + 1); -- [LINE 553]
      ret[idx] = to_luaobj(repr(v)); -- [LINE 554]
      idx = (idx + 1); -- [LINE 554]
      sep = ', '; -- [LINE 555]
    end;
    ret[idx] = e; -- [LINE 557]
    idx = (idx + 1); -- [LINE 557]
    return table.concat(ret); -- [LINE 559]
  end;
  setfenv(make_repr, _G);
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(LuaValueOnlySequance, type);
LuaValueOnlySequance = register_pyobj(LuaValueOnlySequance);
list = (function(_G) -- (class list:LuaValueOnlySequance)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaValueOnlySequance}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'list';
  function __repr__(self)
    return self.make_repr('[', ']'); -- [LINE 565]
  end;
  setfenv(__repr__, _G);
  function __setattr__(self, key, value)
    error('Not allowed'); -- [LINE 568]
  end;
  setfenv(__setattr__, _G);
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(list, type);
list = register_pyobj(list);
tuple = (function(_G) -- (class tuple:LuaValueOnlySequance)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaValueOnlySequance}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'tuple';
  function __repr__(self)
    return self.make_repr('(', ')'); -- [LINE 574]
  end;
  setfenv(__repr__, _G);
  function __setattr__(self, key, value)
    error('Not allowed'); -- [LINE 577]
  end;
  setfenv(__setattr__, _G);
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(tuple, type);
tuple = register_pyobj(tuple);
str = (function(_G) -- (class str:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'str';
  function __init__(self, value)
    if is_pyobj(value) then -- [LINE 583]
      value = _OP__Str__(value); -- [LINE 584]
      value = to_luaobj(value); -- [LINE 585]
    end;
    ObjValue[self] = value; -- [LINE 587]
  end;
  setfenv(__init__, _G);
  function __str__(self)
    return self; -- [LINE 590]
  end;
  setfenv(__str__, _G);
  function __repr__(self)
    return str(lua.concat("'", ObjValue[self], "'")); -- [LINE 593]
  end;
  setfenv(__repr__, _G);
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(str, type);
str = register_pyobj(str);
local function make_bool(value)
  local instance = {['value'] = value}; -- [LINE 596]
  register_pyobj(instance); -- [LINE 597]
  setmetatable(instance, bool); -- [LINE 598]
  return instance; -- [LINE 600]
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
    if not inited then -- [LINE 606]
      local instance = object.__new__(cls); -- [LINE 607]
      instance.value = value; -- [LINE 608]
      return instance; -- [LINE 609]
    end;
    if is_pyobj(value) then -- [LINE 611]
      value = _OP__Bool__(value); -- [LINE 612]
    else
      value = value and true or false; -- [LINE 615]
    end;
    if value == true then -- [LINE 617]
      return True; -- [LINE 618]
    elseif value == false then -- [LINE 619]
      return False; -- [LINE 620]
    elseif is_pyobj(value) and type(value) == bool then -- [LINE 621]
      return value; -- [LINE 622]
    end;
    error('__Bool__ are returned unknown value.'); -- [LINE 624]
  end;
  setfenv(__new__, _G);
  function __repr__(self)
    if self.value == true then -- [LINE 627]
      return str('True'); -- [LINE 628]
    elseif self.value == false then -- [LINE 629]
      return str('False'); -- [LINE 630]
    end;
  end;
  setfenv(__repr__, _G);
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(bool, type);
bool = register_pyobj(bool);
int = (function(_G) -- (class int:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'int';
  function __add__(self, other)
    return int((ObjValue[self] + ObjValue[other])); -- [LINE 638]
  end;
  setfenv(__add__, _G);
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(int, type);
int = register_pyobj(int);
dict = (function(_G) -- (class dict:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'dict';
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(dict, type);
dict = register_pyobj(dict);
register_builtins_class(object); -- [LINE 646]
register_builtins_class(type, object); -- [LINE 647]
register_builtins_class(list, object); -- [LINE 648]
register_builtins_class(str, object); -- [LINE 649]
register_builtins_class(int, object); -- [LINE 650]
register_builtins_class(dict, object); -- [LINE 651]
True = bool(true); -- [LINE 652]
False = bool(false); -- [LINE 653]
inited = True; -- [LINE 654]
local function table_len(x)
  local count = 0; -- [LINE 660]
  local k, v;
  for k, v in pairs(x) do -- [LINE 661]
    count = (count + 1); -- [LINE 661]
  end;
  return count; -- [LINE 662]
end;
local x = list({int(1), int(2), int(3)}); -- [LINE 664]
local y = int(5); -- [LINE 665]
local z = int(7); -- [LINE 666]
print(x); -- [LINE 668]
print(True == nil); -- [LINE 669]
print(True); -- [LINE 670]
print(issubclass(int, object)); -- [LINE 671]
print(int.mro()); -- [LINE 672]
print(_OP__Add__(y, z)); -- [LINE 673]
