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
lua = {}; -- [LINE 8]
local key, value;
for key, value in pairs(_G) do -- [LINE 9]
  lua[key] = value; -- [LINE 10]
end;
local builtins = 'builtins'; -- [LINE 12]
local TAG = '[PY]'; -- [LINE 13]
local OBJ_ID = 0; -- [LINE 14]
local ObjectID_FromRef = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 16]
local ObjectRef_FromID = setmetatable({}, {['__mode'] = 'v'}); -- [LINE 17]
local __PCEX__ = '__PCEX__'; -- [LINE 19]
local methods = {'__new__', '__init__', '__del__', '__repr__', '__str__', '__bytes__', '__format__', '__lt__', '__le__', '__eq__', '__ne__', '__gt__', '__ge__', '__hash__', '__bool__', '__getattr__', '__getattribute__', '__setattr__', '__delattr__', '__dir__', '__get__', '__set__', '__delete__', '__slots__', '__call__', '__len__', '__getitem__', '__setitem__', '__delitem__', '__iter__', '__reversed__', '__contains__', '__add__', '__sub__', '__mul__', '__truediv__', '__floordiv__', '__mod__', '__divmod__', '__pow__', '__lshift__', '__rshift__', '__and__', '__xor__', '__or__', '__radd__', '__rsub__', '__rmul__', '__rtruediv__', '__rfloordiv__', '__rmod__', '__rdivmod__', '__rpow__', '__rlshift__', '__rrshift__', '__rand__', '__rxor__', '__ror__', '__iadd__', '__isub__', '__imul__', '__itruediv__', '__ifloordiv__', '__imod__', '__ipow__', '__ilshift__', '__irshift__', '__iand__', '__ixor__', '__ior__', '__neg__', '__pos__', '__abs__', '__invert__', '__complex__', '__int__', '__float__', '__round__', '__index__', '__enter__', '__exit__', '__lua__'}; -- [LINE 20]
local function lua_len(obj)
  return #obj; -- [LINE 23]
end;
local function lua_concat(...)
  local args = {...};
  local r = ''; -- [LINE 26]
  local _, x;
  for _, x in pairs(args) do -- [LINE 27]
    x = tostring(x); -- [LINE 28]
    r = r..x; -- [LINE 29]
  end;
  return r; -- [LINE 31]
end;
lua.len = lua_len; -- [LINE 33]
lua.concat = lua_concat; -- [LINE 34]
local function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 37]
    error('This is not number', 2); -- [LINE 38]
  end;
  return math.floor(num) ~= num; -- [LINE 40]
end;
local function error(msg, level)
  if level == nil then -- [LINE 43]
    level = 1; -- [LINE 44]
  end;
  level = (level + 1); -- [LINE 46]
  lua.error(lua.concat(TAG, ' ', msg), level); -- [LINE 47]
end;
local function require_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 50]
    if value == nil then -- [LINE 51]
      error('SystemError: Not Enough Item'); -- [LINE 52]
    end;
  end;
  return True; -- [LINE 54]
end;
local function nonrequire_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 57]
    if value ~= nil then -- [LINE 58]
      error('SystemError: Not Enough Item'); -- [LINE 59]
    end;
  end;
  return True; -- [LINE 61]
end;
function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 64]
    error('This is not number', 2); -- [LINE 65]
  end;
  return math.floor(num) ~= num; -- [LINE 67]
end;
local function is_pyobj(obj)
  local mtable = lua.getmetatable(obj); -- [LINE 70]
  return mtable and rawget(mtable, TAG) == TAG or false; -- [LINE 71]
end;
local function to_pyobj(obj)
  if is_pyobj(obj) then -- [LINE 74]
    return obj; -- [LINE 75]
  else
    return LuaObject(obj); -- [LINE 77]
  end;
end;
local function to_luaobj(obj)
  if is_pyobj(obj) then -- [LINE 91]
    return _OP__Lua__(obj); -- [LINE 92]
  else
    return obj; -- [LINE 94]
  end;
end;
local function require_pyobj(...)
  local objs = {...};
  local idx, obj;
  for idx, obj in pairs(objs) do -- [LINE 97]
    if not is_pyobj(obj) then -- [LINE 98]
      lua.print(lua.type(obj), obj); -- [LINE 99]
      error('Require python object.'); -- [LINE 100]
    end;
  end;
  return true; -- [LINE 102]
end;
local function register_pyobj(obj)
  OBJ_ID = (OBJ_ID + 1); -- [LINE 106]
  local obj_id = OBJ_ID; -- [LINE 107]
  ObjectID_FromRef[obj] = obj_id; -- [LINE 109]
  ObjectRef_FromID[obj_id] = obj; -- [LINE 110]
  return obj; -- [LINE 111]
end;
local function build_builtins_cls_bases(cls, ...)
  local bases = {...};
  local mro = {}; -- [LINE 114]
  local idx = 1; -- [LINE 115]
  for i = #bases, 1, -1 do --; -- [LINE 116]
  if true then -- [LINE 117]
    local base = bases[i]; -- [LINE 118]
    mro[idx] = base; -- [LINE 119]
    idx = (idx + 1); -- [LINE 120]
  end;
  end; -- [LINE 121]
  mro[idx] = cls; -- [LINE 123]
  rawset(cls, '__module__', str('builtins')); -- [LINE 124]
  rawset(cls, '__mro__', tuple(mro)); -- [LINE 125]
  return cls; -- [LINE 126]
end;
local function Fail_OP(a, ax)
  error(lua.concat(to_luaobj(repr(a)), ' are not support ', methods[ax])); -- [LINE 129]
end;
local function Fail_OP_Raw(a, raw_ax)
  error(lua.concat(to_luaobj(repr(a)), ' are not support ', raw_ax)); -- [LINE 132]
end;
local function Fail_OP_Math_Raw(a, b, raw_ax)
  error(lua.concat('Not support ', to_luaobj(repr(a)), ' ', raw_ax, ' ', to_luaobj(repr(b)))); -- [LINE 135]
end;
local function Fail_OP_Math(a, b, ax, extra)
  if extra == nil then -- [LINE 138]
    extra = ''; -- [LINE 139]
  else
    extra = lua.concat(' ', extra); -- [LINE 141]
  end;
  error(lua.concat('Not support ', to_luaobj(repr(a)), ' ', methods[ax], ' ', to_luaobj(repr(b)), extra)); -- [LINE 143]
end;
local function Fail_OP_Math_Pow(a, b, ax, c)
  local extra = ''; -- [LINE 146]
  if c then -- [LINE 147]
    extra = lua.concat('% ', to_luaobj(repr(c))); -- [LINE 148]
  end;
  Fail_OP_Math(a, b, ax, c); -- [LINE 150]
end;
function repr(obj)
  if is_pyobj(obj) then -- [LINE 154]
    return _OP__Repr__(obj); -- [LINE 155]
  else
    return lua.concat('@(', tostring(obj), ')'); -- [LINE 157]
  end;
end;
function print(...)
  local args = {...};
  local write = lua.io.write; -- [LINE 161]
  local sep = ' '; -- [LINE 162]
  local _, arg;
  for _, arg in pairs(args) do -- [LINE 164]
    if is_pyobj(arg) then -- [LINE 165]
      arg = str(arg); -- [LINE 166]
    else
      arg = repr(arg); -- [LINE 168]
    end;
    arg = to_luaobj(arg); -- [LINE 170]
    write(arg); -- [LINE 171]
    write(sep); -- [LINE 172]
  end;
  write('\n'); -- [LINE 174]
end;
function isinstance(cls, targets)
  require_pyobj(obj); -- [LINE 178]
  if type(cls) ~= type then -- [LINE 180]
    cls = type(obj); -- [LINE 181]
  end;
  local mro = cls.mro(); -- [LINE 183]
  assert(type(mro) == tuple); -- [LINE 184]
  local _, supercls;
  for _, supercls in pairs(mro.value) do -- [LINE 186]
    require_pyobj(supercls); -- [LINE 187]
    if supercls == targets then -- [LINE 188]
      return True; -- [LINE 189]
    end;
  end;
  return False; -- [LINE 191]
end;
local function issubclass(cls, targets)
  require_pyobj(obj); -- [LINE 194]
  if type(cls) ~= type then -- [LINE 196]
    error('issubclass() arg 1 must be a class'); -- [LINE 197]
  end;
  local mro = cls.mro(); -- [LINE 199]
  assert(type(mro) == tuple); -- [LINE 200]
  local _, supercls;
  for _, supercls in pairs(mro.value) do -- [LINE 202]
    require_pyobj(supercls); -- [LINE 203]
    if supercls == targets then -- [LINE 204]
      return True; -- [LINE 205]
    end;
  end;
  return False; -- [LINE 207]
end;
function id(obj)
  if is_pyobj(obj) then -- [LINE 211]
    return int(ObjectID_FromRef[obj]); -- [LINE 212]
  end;
  Fail_OP_Raw(obj, '__id__!'); -- [LINE 214]
end;
local function OP_Call(ax)
  local function func(a, ...)
    local args = {...};
    assert(require_pyobj(a)); -- [LINE 218]
    local f = rawget(getmetatable(a), __PCEX__)[ax]; -- [LINE 219]
    if f then -- [LINE 220]
      return f(a, ...); -- [LINE 221]
    end;
    Fail_OP(a, ax); -- [LINE 223]
  end;
  return func; -- [LINE 224]
end;
local function OP_Math2(ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 228]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 229]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 230]
    local f = am[ax]; -- [LINE 232]
    if f then -- [LINE 233]
      local ret = f(a, b); -- [LINE 234]
      if ret ~= NotImplemented then -- [LINE 235]
        return ret; -- [LINE 235]
      end;
    end;
    f = bm[bx]; -- [LINE 237]
    if f then -- [LINE 238]
      ret = f(b, a); -- [LINE 239]
      if ret ~= NotImplemented then -- [LINE 240]
        return ret; -- [LINE 240]
      end;
    end;
    Fail_OP_Math(a, b, ax); -- [LINE 242]
  end;
  return func; -- [LINE 244]
end;
local function OP_Math3(cx, ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 248]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 249]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 250]
    local f = am[cx]; -- [LINE 252]
    if f then -- [LINE 253]
      local ret = f(a, b); -- [LINE 254]
      if ret ~= NotImplemented then -- [LINE 255]
        return ret; -- [LINE 255]
      end;
    end;
    f = am[ax]; -- [LINE 258]
    if f then -- [LINE 259]
      ret = f(a, b); -- [LINE 260]
      if ret ~= NotImplemented then -- [LINE 261]
        return ret; -- [LINE 261]
      end;
    end;
    f = bm[bx]; -- [LINE 263]
    if f then -- [LINE 264]
      ret = f(b, a); -- [LINE 265]
      if ret ~= NotImplemented then -- [LINE 266]
        return ret; -- [LINE 266]
      end;
    end;
    Fail_OP_Math(a, b, cx); -- [LINE 268]
  end;
  return func; -- [LINE 270]
end;
local function OP_Math2_Pow(ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 274]
    assert(require_pyobj(c) or c == nil); -- [LINE 275]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 276]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 277]
    local f = am[ax]; -- [LINE 279]
    if f then -- [LINE 280]
      local ret = f(a, b, c); -- [LINE 281]
      if ret ~= NotImplemented then -- [LINE 282]
        return ret; -- [LINE 282]
      end;
    end;
    if c ~= nil then -- [LINE 284]
      f = bm[bx]; -- [LINE 289]
      if f then -- [LINE 290]
        ret = f(b, a); -- [LINE 291]
        if ret ~= NotImplemented then -- [LINE 292]
          return ret; -- [LINE 292]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 294]
  end;
  return func; -- [LINE 296]
end;
local function OP_Math3_Pow(cx, ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 300]
    assert(require_pyobj(c) or c == nil); -- [LINE 301]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 302]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 303]
    local f = am[cx]; -- [LINE 305]
    if f then -- [LINE 306]
      local ret = f(a, b, c); -- [LINE 307]
      if ret ~= NotImplemented then -- [LINE 308]
        return ret; -- [LINE 308]
      end;
    end;
    f = am[ax]; -- [LINE 310]
    if f then -- [LINE 311]
      ret = f(a, b, c); -- [LINE 312]
      if ret ~= NotImplemented then -- [LINE 313]
        return ret; -- [LINE 313]
      end;
    end;
    if c ~= nil then -- [LINE 315]
      f = bm[bx]; -- [LINE 316]
      if f then -- [LINE 317]
        ret = f(b, a); -- [LINE 318]
        if ret ~= NotImplemented then -- [LINE 319]
          return ret; -- [LINE 319]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 321]
  end;
  return func; -- [LINE 323]
end;
function _OP__Is__(a, b)
  require_pyobj(a, b); -- [LINE 327]
  return ObjectID_FromRef[a] == ObjectID_FromRef[b]; -- [LINE 328]
end;
function _OP__IsNot__(a, b)
  return not _OP__Is__(a, b); -- [LINE 331]
end;
 -- [LINE 333]
_OP__New__ = OP_Call(1); -- [LINE 335]
_OP__Init__ = OP_Call(2); -- [LINE 336]
_OP__Del__ = OP_Call(3); -- [LINE 337]
_OP__Repr__ = OP_Call(4); -- [LINE 338]
_OP__Str__ = OP_Call(5); -- [LINE 339]
_OP__Bytes__ = OP_Call(6); -- [LINE 340]
_OP__Format__ = OP_Call(7); -- [LINE 341]
_OP__Lt__ = OP_Call(8); -- [LINE 342]
_OP__Le__ = OP_Call(9); -- [LINE 343]
_OP__Eq__ = OP_Call(10); -- [LINE 344]
_OP__Ne__ = OP_Call(11); -- [LINE 345]
_OP__Gt__ = OP_Call(12); -- [LINE 346]
_OP__Ge__ = OP_Call(13); -- [LINE 347]
_OP__Hash__ = OP_Call(14); -- [LINE 348]
_OP__Bool__ = OP_Call(15); -- [LINE 349]
_OP__Getattr__ = OP_Call(16); -- [LINE 350]
_OP__Getattribute__ = OP_Call(17); -- [LINE 351]
_OP__Setattr__ = OP_Call(18); -- [LINE 352]
_OP__Delattr__ = OP_Call(19); -- [LINE 353]
_OP__Dir__ = OP_Call(20); -- [LINE 354]
_OP__Get__ = OP_Call(21); -- [LINE 355]
_OP__Set__ = OP_Call(22); -- [LINE 356]
_OP__Delete__ = OP_Call(23); -- [LINE 357]
_OP__Slots__ = OP_Call(24); -- [LINE 358]
_OP__Call__ = OP_Call(25); -- [LINE 359]
_OP__Len__ = OP_Call(26); -- [LINE 360]
_OP__Getitem__ = OP_Call(27); -- [LINE 361]
_OP__Setitem__ = OP_Call(28); -- [LINE 362]
_OP__Delitem__ = OP_Call(29); -- [LINE 363]
_OP__Iter__ = OP_Call(30); -- [LINE 364]
_OP__Reversed__ = OP_Call(31); -- [LINE 365]
_OP__Contains__ = OP_Call(32); -- [LINE 366]
_OP__Add__ = OP_Math2(33, 46); -- [LINE 369]
_OP__Sub__ = OP_Math2(34, 47); -- [LINE 370]
_OP__Mul__ = OP_Math2(35, 48); -- [LINE 371]
_OP__Truediv__ = OP_Math2(36, 49); -- [LINE 372]
_OP__Floordiv__ = OP_Math2(37, 50); -- [LINE 373]
_OP__Mod__ = OP_Math2(38, 51); -- [LINE 374]
_OP__Divmod__ = OP_Math2(39, 52); -- [LINE 375]
_OP__Pow__ = OP_Math2_Pow(40, 53); -- [LINE 376]
_OP__Lshift__ = OP_Math2(41, 54); -- [LINE 377]
_OP__Rshift__ = OP_Math2(42, 55); -- [LINE 378]
_OP__And__ = OP_Math2(43, 56); -- [LINE 379]
_OP__Xor__ = OP_Math2(44, 57); -- [LINE 380]
_OP__Or__ = OP_Math2(45, 58); -- [LINE 381]
_OP__Iadd__ = OP_Math3(59, 33, 46); -- [LINE 384]
_OP__Isub__ = OP_Math3(60, 34, 47); -- [LINE 385]
_OP__Imul__ = OP_Math3(61, 35, 48); -- [LINE 386]
_OP__Itruediv__ = OP_Math3(62, 36, 49); -- [LINE 387]
_OP__Ifloordiv__ = OP_Math3(63, 37, 50); -- [LINE 388]
_OP__Imod__ = OP_Math3(64, 38, 51); -- [LINE 389]
_OP__Ipow__ = OP_Math3_Pow(65, 40, 53); -- [LINE 390]
_OP__Ilshift__ = OP_Math3(66, 41, 54); -- [LINE 391]
_OP__Irshift__ = OP_Math3(67, 42, 55); -- [LINE 392]
_OP__Iand__ = OP_Math3(68, 43, 56); -- [LINE 393]
_OP__Ixor__ = OP_Math3(69, 44, 57); -- [LINE 394]
_OP__Ior__ = OP_Math3(70, 45, 58); -- [LINE 395]
_OP__Neg__ = OP_Call(71); -- [LINE 398]
_OP__Pos__ = OP_Call(72); -- [LINE 399]
_OP__Abs__ = OP_Call(73); -- [LINE 400]
_OP__Invert__ = OP_Call(74); -- [LINE 401]
_OP__Complex__ = OP_Call(75); -- [LINE 402]
_OP__Int__ = OP_Call(76); -- [LINE 403]
_OP__Float__ = OP_Call(77); -- [LINE 404]
_OP__Round__ = OP_Call(78); -- [LINE 405]
_OP__Index__ = OP_Call(79); -- [LINE 406]
_OP__Enter__ = OP_Call(80); -- [LINE 407]
_OP__Exit__ = OP_Call(81); -- [LINE 408]
_OP__Lua__ = OP_Call(82); -- [LINE 411]
 -- [LINE 412]
object = (function(_G) -- (class object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  __name__ = 'object';
  function __init__(self)
  end;
  setfenv(__init__, _G)
  function __call(self, ...)
    local args = {...};
    return _OP__Call__(self, ...); -- [LINE 421]
  end;
  setfenv(__call, _G)
  function __index(self, key)
    return _OP__Getattribute__(self, key); -- [LINE 424]
  end;
  setfenv(__index, _G)
  function __newindex(self, key, value)
    return _OP__Setattr__(self, key, value); -- [LINE 427]
  end;
  setfenv(__newindex, _G)
  function __tostring(self)
    return lua.concat('#(', to_luaobj(repr(self)), ')'); -- [LINE 430]
  end;
  setfenv(__tostring, _G)
  function __new__(cls, ...)
    local args = {...};
    local instance = register_pyobj({}); -- [LINE 433]
    lua.setmetatable(instance, cls); -- [LINE 434]
    _OP__Init__(instance, ...); -- [LINE 435]
    return instance; -- [LINE 437]
  end;
  setfenv(__new__, _G)
  function __getattribute__(self, k)
    local v = rawget(self, k); -- [LINE 440]
    if v ~= nil then -- [LINE 441]
      return v; -- [LINE 442]
    end;
    local mt = getmetatable(self); -- [LINE 444]
    v = rawget(mt, k); -- [LINE 445]
    if v ~= nil then -- [LINE 446]
      if lua.type(v) == 'function' then -- [LINE 447]
        return (function(...) return v(self, unpack({...})) end); -- [LINE 448]
      else
        return v; -- [LINE 450]
      end;
    end;
    error(lua.concat("Not found '", k, "' attribute.")); -- [LINE 452]
  end;
  setfenv(__getattribute__, _G)
  function __setattr__(self, key, value)
    rawset(self, key, value); -- [LINE 456]
  end;
  setfenv(__setattr__, _G)
  function __str__(self)
    return _OP__Repr__(self); -- [LINE 459]
  end;
  setfenv(__str__, _G)
  function __repr__(self)
    local mtable = getmetatable(self); -- [LINE 462]
    return str(concat('<object ', mtable.__name__, ' at ', tostring(self.__id), '>')); -- [LINE 463]
  end;
  setfenv(__repr__, _G)
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
object = register_pyobj(object);
rawset(object, TAG, TAG); -- [LINE 465]
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
    local instance = cls.__new__(cls, ...); -- [LINE 471]
    register_pyobj(instance); -- [LINE 472]
    return instance; -- [LINE 474]
  end;
  setfenv(__call__, _G)
  function __repr__(cls)
    return str(lua.concat("<class '", cls.__name__, "'>")); -- [LINE 477]
  end;
  setfenv(__repr__, _G)
  function mro(cls)
    return cls.__mro__; -- [LINE 480]
  end;
  setfenv(mro, _G)
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
type = register_pyobj(type);
local builtins_type = (function(_G) -- (class builtins_type:type)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({type}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'builtins_type';
  __name__ = 'type'; -- [LINE 484]
  function __setattr__(self, name)
    error('Not allowed setattr for builtins type.'); -- [LINE 487]
  end;
  setfenv(__setattr__, _G)
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
builtins_type = register_pyobj(builtins_type);
local ptype = (function(_G) -- (class ptype:builtins_type)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({builtins_type}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'ptype';
  function __call__(cls, ...)
    local args = {...};
    if lua.len(args) == 1 then -- [LINE 492]
      require_pyobj(args[1]); -- [LINE 493]
      return getmetatable(args[1]); -- [LINE 494]
    elseif lua.len(args) == 3 then -- [LINE 495]
    else
      error('Unexcepted arguments.'); -- [LINE 498]
    end;
  end;
  setfenv(__call__, _G)
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
ptype = register_pyobj(ptype);
setmetatable(object, builtins_type); -- [LINE 500]
setmetatable(type, ptype); -- [LINE 501]
setmetatable(ptype, ptype); -- [LINE 502]
local LuaObject = (function(_G) -- (class LuaObject:object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'LuaObject';
  LuaObject = true; -- [LINE 507]
  function __init__(self, obj)
    local mtable = getmetatable(obj); -- [LINE 511]
    if mtable and rawget(mtable, 'LuaObject') then -- [LINE 512]
      obj = to_luaobj(obj); -- [LINE 513]
    end;
    object.__setattr__(self, 'value', obj); -- [LINE 515]
  end;
  setfenv(__init__, _G)
  function __str__(self)
    return str(_OP__Repr__(self)); -- [LINE 518]
  end;
  setfenv(__str__, _G)
  function __repr__(self)
    return str(tostring(self.value)); -- [LINE 521]
  end;
  setfenv(__repr__, _G)
  function __lua__(self)
    return self.value; -- [LINE 524]
  end;
  setfenv(__lua__, _G)
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
  function __init__(self, obj)
    self.check_type(obj); -- [LINE 529]
    object.__setattr__(self, 'value', obj); -- [LINE 530]
  end;
  setfenv(__init__, _G)
  function check_type(self, obj)
    if obj[lua.len(obj)] == nil then -- [LINE 533]
    elseif obj[1] == nil then -- [LINE 534]
    elseif obj[0] ~= nil then -- [LINE 535]
    else
      return true; -- [LINE 537]
    end;
    return false; -- [LINE 539]
  end;
  setfenv(check_type, _G)
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
    local ret = {}; -- [LINE 545]
    local idx = 1; -- [LINE 546]
    local sep = ''; -- [LINE 548]
    ret[idx] = '['; -- [LINE 549]
    idx = (idx + 1); -- [LINE 549]
    local k, v;
    for k, v in pairs(self.value) do -- [LINE 550]
      ret[idx] = sep; -- [LINE 551]
      idx = (idx + 1); -- [LINE 551]
      ret[idx] = to_luaobj(repr(v)); -- [LINE 552]
      idx = (idx + 1); -- [LINE 552]
      sep = ', '; -- [LINE 553]
    end;
    ret[idx] = ']'; -- [LINE 555]
    idx = (idx + 1); -- [LINE 555]
    return table.concat(ret); -- [LINE 557]
  end;
  setfenv(__repr__, _G)
  function __setattr__(self, key, value)
    error('Not allowed'); -- [LINE 560]
  end;
  setfenv(__setattr__, _G)
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
    local ret = {}; -- [LINE 566]
    local idx = 1; -- [LINE 567]
    local sep = ''; -- [LINE 569]
    ret[idx] = '('; -- [LINE 570]
    idx = (idx + 1); -- [LINE 570]
    local k, v;
    for k, v in pairs(self.value) do -- [LINE 571]
      ret[idx] = sep; -- [LINE 572]
      idx = (idx + 1); -- [LINE 572]
      ret[idx] = to_luaobj(repr(v)); -- [LINE 573]
      idx = (idx + 1); -- [LINE 573]
      sep = ', '; -- [LINE 574]
    end;
    ret[idx] = ')'; -- [LINE 576]
    idx = (idx + 1); -- [LINE 576]
    return table.concat(ret); -- [LINE 578]
  end;
  setfenv(__repr__, _G)
  function __setattr__(self, key, value)
    error('Not allowed'); -- [LINE 581]
  end;
  setfenv(__setattr__, _G)
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
    if is_pyobj(value) then -- [LINE 587]
      value = _OP__Str__(value); -- [LINE 588]
      value = to_luaobj(value); -- [LINE 589]
    end;
    self.value = value; -- [LINE 591]
  end;
  setfenv(__init__, _G)
  function __str__(self)
    return self; -- [LINE 594]
  end;
  setfenv(__str__, _G)
  function __repr__(self)
    return str(lua.concat("'", self.value, "'")); -- [LINE 597]
  end;
  setfenv(__repr__, _G)
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(str, type);
str = register_pyobj(str);
bool = (function(_G) -- (class bool:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'bool';
  function __new__(self, value)
    if is_pyobj(value) then -- [LINE 603]
      value = _OP__Bool__(value); -- [LINE 604]
    else
      value = value and true or false; -- [LINE 607]
    end;
    if value == true then -- [LINE 609]
      return True; -- [LINE 610]
    elseif value == false then -- [LINE 611]
      return False; -- [LINE 612]
    elseif is_pyobj(value) and type(value) == bool then -- [LINE 613]
      return value; -- [LINE 614]
    end;
    error('__Bool__ are returned unknown value.'); -- [LINE 616]
  end;
  setfenv(__new__, _G)
  function __repr__(self)
    if self.value == true then -- [LINE 619]
      return str('True'); -- [LINE 620]
    elseif self.value == false then -- [LINE 621]
      return str('False'); -- [LINE 622]
    end;
  end;
  setfenv(__repr__, _G)
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(bool, type);
bool = register_pyobj(bool);
local function make_bool(value)
  local instance = {['value'] = value}; -- [LINE 625]
  register_pyobj(instance); -- [LINE 626]
  setmetatable(instance, bool); -- [LINE 627]
  return instance; -- [LINE 629]
end;
True = make_bool(true); -- [LINE 631]
False = make_bool(false); -- [LINE 632]
int = (function(_G) -- (class int:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'int';
  function __add__(self, other)
    return int((self.value + other.value)); -- [LINE 639]
  end;
  setfenv(__add__, _G)
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
build_builtins_cls_bases(object); -- [LINE 646]
build_builtins_cls_bases(type, object); -- [LINE 647]
build_builtins_cls_bases(list, object); -- [LINE 648]
build_builtins_cls_bases(str, object); -- [LINE 649]
build_builtins_cls_bases(int, object); -- [LINE 650]
build_builtins_cls_bases(dict, object); -- [LINE 651]
local x = list({int(1), int(2), int(3)}); -- [LINE 656]
local y = int(5); -- [LINE 657]
local z = int(7); -- [LINE 658]
print(x); -- [LINE 660]
print(True == nil); -- [LINE 661]
print(True); -- [LINE 662]
print(issubclass(int, object)); -- [LINE 663]
print(int.mro()); -- [LINE 664]
print(_OP__Add__(y, z)); -- [LINE 665]
