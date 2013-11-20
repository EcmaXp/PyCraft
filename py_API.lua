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
local TAG = '[PY]'; -- [LINE 12]
local OBJ_ID = 0; -- [LINE 13]
local __PCEX__ = '__PCEX__'; -- [LINE 15]
local methods = {'__new__', '__init__', '__del__', '__repr__', '__str__', '__bytes__', '__format__', '__lt__', '__le__', '__eq__', '__ne__', '__gt__', '__ge__', '__hash__', '__bool__', '__getattr__', '__getattribute__', '__setattr__', '__delattr__', '__dir__', '__get__', '__set__', '__delete__', '__slots__', '__call__', '__len__', '__getitem__', '__setitem__', '__delitem__', '__iter__', '__reversed__', '__contains__', '__add__', '__sub__', '__mul__', '__truediv__', '__floordiv__', '__mod__', '__divmod__', '__pow__', '__lshift__', '__rshift__', '__and__', '__xor__', '__or__', '__radd__', '__rsub__', '__rmul__', '__rtruediv__', '__rfloordiv__', '__rmod__', '__rdivmod__', '__rpow__', '__rlshift__', '__rrshift__', '__rand__', '__rxor__', '__ror__', '__iadd__', '__isub__', '__imul__', '__itruediv__', '__ifloordiv__', '__imod__', '__ipow__', '__ilshift__', '__irshift__', '__iand__', '__ixor__', '__ior__', '__neg__', '__pos__', '__abs__', '__invert__', '__complex__', '__int__', '__float__', '__round__', '__index__', '__enter__', '__exit__', '__lua__'}; -- [LINE 16]
local function lua_len(obj)
  return #obj; -- [LINE 19]
end;
local function lua_concat(...)
  local args = {...};
  local r = ''; -- [LINE 22]
  local _, x;
  for _, x in pairs(args) do -- [LINE 23]
    x = tostring(x); -- [LINE 24]
    r = r..x; -- [LINE 25]
  end;
  return r; -- [LINE 27]
end;
lua.len = lua_len; -- [LINE 29]
lua.concat = lua_concat; -- [LINE 30]
local function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 33]
    error('This is not number', 2); -- [LINE 34]
  end;
  return math.floor(num) ~= num; -- [LINE 36]
end;
local function error(msg, level)
  if level == nil then -- [LINE 39]
    level = 1; -- [LINE 40]
  end;
  level = (level + 1); -- [LINE 42]
  lua.error(lua.concat(TAG, ' ', msg), level); -- [LINE 43]
end;
local function require_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 46]
    if value == nil then -- [LINE 47]
      error('SystemError: Not Enough Item'); -- [LINE 48]
    end;
  end;
  return True; -- [LINE 50]
end;
local function nonrequire_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 53]
    if value ~= nil then -- [LINE 54]
      error('SystemError: Not Enough Item'); -- [LINE 55]
    end;
  end;
  return True; -- [LINE 57]
end;
function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 60]
    error('This is not number', 2); -- [LINE 61]
  end;
  return math.floor(num) ~= num; -- [LINE 63]
end;
local function is_pyobj(obj)
  local mtable = lua.getmetatable(obj); -- [LINE 66]
  return mtable and rawget(mtable, TAG) == TAG or false; -- [LINE 67]
end;
local function to_pyobj(obj)
  if is_pyobj(obj) then -- [LINE 70]
    return obj; -- [LINE 71]
  else
    return LuaObject(obj); -- [LINE 73]
  end;
end;
local function to_luaobj(obj)
  if is_pyobj(obj) then -- [LINE 87]
    return _OP__Lua__(obj); -- [LINE 88]
  else
    return obj; -- [LINE 90]
  end;
end;
local function require_pyobj(...)
  local objs = {...};
  local idx, obj;
  for idx, obj in pairs(objs) do -- [LINE 93]
    if not is_pyobj(obj) then -- [LINE 94]
      lua.print(lua.type(obj), obj); -- [LINE 95]
      error('Require python object.'); -- [LINE 96]
    end;
  end;
  return true; -- [LINE 98]
end;
function repr(obj)
  if is_pyobj(obj) then -- [LINE 102]
    return _OP__Repr__(obj); -- [LINE 103]
  else
    return lua.concat('@(', tostring(obj), ')'); -- [LINE 105]
  end;
end;
object = (function(_G) -- (class object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  __name__ = 'object';
  function __init__(self)
  end;
  setfenv(__init__, _G)
  function __call(self, ...)
    local args = {...};
    return _OP__Call__(self, ...); -- [LINE 113]
  end;
  setfenv(__call, _G)
  function __index(self, key)
    return _OP__Getattribute__(self, key); -- [LINE 116]
  end;
  setfenv(__index, _G)
  function __newindex(self, key, value)
    return _OP__Setattr__(self, key, value); -- [LINE 119]
  end;
  setfenv(__newindex, _G)
  function __tostring(self)
    return lua.concat('#(', to_luaobj(repr(self)), ')'); -- [LINE 122]
  end;
  setfenv(__tostring, _G)
  function __new__(cls, ...)
    local args = {...};
    OBJ_ID = (OBJ_ID + 1); -- [LINE 126]
    local instance = {['__id'] = OBJ_ID}; -- [LINE 128]
    lua.setmetatable(instance, cls); -- [LINE 129]
    _OP__Init__(instance, ...); -- [LINE 130]
    return instance; -- [LINE 132]
  end;
  setfenv(__new__, _G)
  function __getattribute__(self, key)
    local value = rawget(self, key); -- [LINE 135]
    if value ~= nil then -- [LINE 136]
      return value; -- [LINE 137]
    end;
    local mtable = getmetatable(self); -- [LINE 139]
    value = rawget(mtable, key); -- [LINE 140]
    if value ~= nil then -- [LINE 141]
      if lua.type(value) == 'function' then -- [LINE 142]
        return (function(...) return value(self, unpack({...})) end); -- [LINE 143]
      else
        return value; -- [LINE 145]
      end;
    end;
    error(lua.concat("Not found '", key, "' attribute.")); -- [LINE 147]
  end;
  setfenv(__getattribute__, _G)
  function __setattr__(self, key, value)
    rawset(self, key, value); -- [LINE 151]
  end;
  setfenv(__setattr__, _G)
  function __repr__(self)
    local mtable = getmetatable(self); -- [LINE 154]
    return str(concat('<object ', mtable.__name__, ' at ', tostring(self.__id), '>')); -- [LINE 155]
  end;
  setfenv(__repr__, _G)
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
rawset(object, TAG, TAG); -- [LINE 157]
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
    return cls.__new__(cls, ...); -- [LINE 162]
  end;
  setfenv(__call__, _G)
  function __repr__(cls)
    return str(lua.concat("<class '", cls.__name__, "'>")); -- [LINE 165]
  end;
  setfenv(__repr__, _G)
  function mro(cls)
    return cls.__mro__; -- [LINE 168]
  end;
  setfenv(mro, _G)
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
local builtins_type = (function(_G) -- (class builtins_type:type)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({type}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'builtins_type';
  __name__ = 'type'; -- [LINE 171]
  function __setattr__(self, name)
    error('Not allowed setattr for builtins type.'); -- [LINE 174]
  end;
  setfenv(__setattr__, _G)
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
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
    if lua.len(args) == 1 then -- [LINE 178]
      require_pyobj(args[1]); -- [LINE 179]
      return getmetatable(args[1]); -- [LINE 180]
    elseif lua.len(args) == 3 then -- [LINE 181]
    else
      error('Unexcepted arguments.'); -- [LINE 184]
    end;
  end;
  setfenv(__call__, _G)
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(object, builtins_type); -- [LINE 186]
setmetatable(type, ptype); -- [LINE 187]
setmetatable(ptype, ptype); -- [LINE 188]
local LuaObject = (function(_G) -- (class LuaObject:object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'LuaObject';
  LuaObject = true; -- [LINE 192]
  function __init__(self, obj)
    local mtable = getmetatable(obj); -- [LINE 196]
    if mtable and rawget(mtable, 'LuaObject') then -- [LINE 197]
      obj = to_luaobj(obj); -- [LINE 198]
    end;
    object.__setattr__(self, 'value', obj); -- [LINE 200]
  end;
  setfenv(__init__, _G)
  function __str__(self)
    return str(_OP__Repr__(self)); -- [LINE 203]
  end;
  setfenv(__str__, _G)
  function __repr__(self)
    return str(tostring(self.value)); -- [LINE 206]
  end;
  setfenv(__repr__, _G)
  function __lua__(self)
    return self.value; -- [LINE 209]
  end;
  setfenv(__lua__, _G)
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(LuaObject, type);
local LuaValueOnlySequance = (function(_G) -- (class LuaValueOnlySequance:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'LuaValueOnlySequance';
  function __init__(self, obj)
    self.check_type(obj); -- [LINE 213]
    object.__setattr__(self, 'value', obj); -- [LINE 214]
  end;
  setfenv(__init__, _G)
  function check_type(self, obj)
    if obj[lua.len(obj)] == nil then -- [LINE 217]
    elseif obj[1] == nil then -- [LINE 218]
    elseif obj[0] ~= nil then -- [LINE 219]
    else
      return true; -- [LINE 221]
    end;
    return false; -- [LINE 223]
  end;
  setfenv(check_type, _G)
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(LuaValueOnlySequance, type);
list = (function(_G) -- (class list:LuaValueOnlySequance)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaValueOnlySequance}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'list';
  function __repr__(self)
    local ret = {}; -- [LINE 228]
    local idx = 1; -- [LINE 229]
    local sep = ''; -- [LINE 231]
    ret[idx] = '['; -- [LINE 232]
    idx = (idx + 1); -- [LINE 232]
    local k, v;
    for k, v in pairs(self.value) do -- [LINE 233]
      ret[idx] = sep; -- [LINE 234]
      idx = (idx + 1); -- [LINE 234]
      ret[idx] = to_luaobj(repr(v)); -- [LINE 235]
      idx = (idx + 1); -- [LINE 235]
      sep = ', '; -- [LINE 236]
    end;
    ret[idx] = ']'; -- [LINE 238]
    idx = (idx + 1); -- [LINE 238]
    return table.concat(ret); -- [LINE 240]
  end;
  setfenv(__repr__, _G)
  function __setattr__(self, key, value)
    error('Not allowed'); -- [LINE 243]
  end;
  setfenv(__setattr__, _G)
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(list, type);
str = (function(_G) -- (class str:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'str';
  function __init__(self, value)
    if is_pyobj(value) then -- [LINE 248]
      value = _OP__Str__(value); -- [LINE 249]
      value = to_luaobj(value); -- [LINE 250]
    end;
    self.value = value; -- [LINE 252]
  end;
  setfenv(__init__, _G)
  function __str__(self)
    return self; -- [LINE 255]
  end;
  setfenv(__str__, _G)
  function __repr__(self)
    return str(lua.concat("'", self.value, "'")); -- [LINE 258]
  end;
  setfenv(__repr__, _G)
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(str, type);
int = (function(_G) -- (class int:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'int';
  function __add__(self, other)
    return int((self.value + other.value)); -- [LINE 264]
  end;
  setfenv(__add__, _G)
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(int, type);
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
function print(...)
  local args = {...};
  local write = lua.io.write; -- [LINE 282]
  local sep = ' '; -- [LINE 283]
  local _, arg;
  for _, arg in pairs(args) do -- [LINE 285]
    write(tostring(to_luaobj(str(arg)))); -- [LINE 286]
    write(sep); -- [LINE 287]
  end;
  write('\n'); -- [LINE 289]
end;
local function OP_Call(x)
  local function func(o, ...)
    local args = {...};
    assert(require_pyobj(o)); -- [LINE 293]
    return rawget(getmetatable(o), __PCEX__)[x](o, ...); -- [LINE 294]
  end;
  return func; -- [LINE 295]
end;
local function Fail_OP_Math(a, b, ax, extra)
  if extra == nil then -- [LINE 298]
    extra = ''; -- [LINE 299]
  else
    extra = lua.concat(' ', extra); -- [LINE 301]
  end;
  error(lua.concat('Not support ', repr(a), ' ', methods[ax], ' ', repr(b), extra)); -- [LINE 303]
end;
local function Fail_OP_Math_Pow(a, b, ax, c)
  local extra = ''; -- [LINE 306]
  if c then -- [LINE 307]
    extra = lua.concat('% ', repr(c)); -- [LINE 308]
  end;
  Fail_OP_Math(a, b, ax, c); -- [LINE 310]
end;
local function OP_Math2(ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 314]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 315]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 316]
    local f = am[ax]; -- [LINE 318]
    if f then -- [LINE 319]
      local ret = f(a, b); -- [LINE 320]
      if ret ~= NotImplemented then -- [LINE 321]
        return ret; -- [LINE 321]
      end;
    end;
    f = bm[bx]; -- [LINE 323]
    if f then -- [LINE 324]
      ret = f(b, a); -- [LINE 325]
      if ret ~= NotImplemented then -- [LINE 326]
        return ret; -- [LINE 326]
      end;
    end;
    Fail_OP_Math(a, b, ax); -- [LINE 328]
  end;
  return func; -- [LINE 330]
end;
local function OP_Math3(cx, ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 334]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 335]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 336]
    local f = am[cx]; -- [LINE 338]
    if f then -- [LINE 339]
      local ret = f(a, b); -- [LINE 340]
      if ret ~= NotImplemented then -- [LINE 341]
        return ret; -- [LINE 341]
      end;
    end;
    f = am[ax]; -- [LINE 344]
    if f then -- [LINE 345]
      ret = f(a, b); -- [LINE 346]
      if ret ~= NotImplemented then -- [LINE 347]
        return ret; -- [LINE 347]
      end;
    end;
    f = bm[bx]; -- [LINE 349]
    if f then -- [LINE 350]
      ret = f(b, a); -- [LINE 351]
      if ret ~= NotImplemented then -- [LINE 352]
        return ret; -- [LINE 352]
      end;
    end;
    Fail_OP_Math(a, b, cx); -- [LINE 354]
  end;
  return func; -- [LINE 356]
end;
local function OP_Math2_Pow(ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 360]
    assert(require_pyobj(c) or c == nil); -- [LINE 361]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 362]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 363]
    local f = am[ax]; -- [LINE 365]
    if f then -- [LINE 366]
      local ret = f(a, b, c); -- [LINE 367]
      if ret ~= NotImplemented then -- [LINE 368]
        return ret; -- [LINE 368]
      end;
    end;
    if c ~= nil then -- [LINE 370]
      f = bm[bx]; -- [LINE 375]
      if f then -- [LINE 376]
        ret = f(b, a); -- [LINE 377]
        if ret ~= NotImplemented then -- [LINE 378]
          return ret; -- [LINE 378]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 380]
  end;
  return func; -- [LINE 382]
end;
local function OP_Math3_Pow(cx, ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 386]
    assert(require_pyobj(c) or c == nil); -- [LINE 387]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 388]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 389]
    local f = am[cx]; -- [LINE 391]
    if f then -- [LINE 392]
      local ret = f(a, b, c); -- [LINE 393]
      if ret ~= NotImplemented then -- [LINE 394]
        return ret; -- [LINE 394]
      end;
    end;
    f = am[ax]; -- [LINE 396]
    if f then -- [LINE 397]
      ret = f(a, b, c); -- [LINE 398]
      if ret ~= NotImplemented then -- [LINE 399]
        return ret; -- [LINE 399]
      end;
    end;
    if c ~= nil then -- [LINE 401]
      f = bm[bx]; -- [LINE 402]
      if f then -- [LINE 403]
        ret = f(b, a); -- [LINE 404]
        if ret ~= NotImplemented then -- [LINE 405]
          return ret; -- [LINE 405]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 407]
  end;
  return func; -- [LINE 409]
end;
 -- [LINE 411]
_OP__New__ = OP_Call(1); -- [LINE 413]
_OP__Init__ = OP_Call(2); -- [LINE 414]
_OP__Del__ = OP_Call(3); -- [LINE 415]
_OP__Repr__ = OP_Call(4); -- [LINE 416]
_OP__Str__ = OP_Call(5); -- [LINE 417]
_OP__Bytes__ = OP_Call(6); -- [LINE 418]
_OP__Format__ = OP_Call(7); -- [LINE 419]
_OP__Lt__ = OP_Call(8); -- [LINE 420]
_OP__Le__ = OP_Call(9); -- [LINE 421]
_OP__Eq__ = OP_Call(10); -- [LINE 422]
_OP__Ne__ = OP_Call(11); -- [LINE 423]
_OP__Gt__ = OP_Call(12); -- [LINE 424]
_OP__Ge__ = OP_Call(13); -- [LINE 425]
_OP__Hash__ = OP_Call(14); -- [LINE 426]
_OP__Bool__ = OP_Call(15); -- [LINE 427]
_OP__Getattr__ = OP_Call(16); -- [LINE 428]
_OP__Getattribute__ = OP_Call(17); -- [LINE 429]
_OP__Setattr__ = OP_Call(18); -- [LINE 430]
_OP__Delattr__ = OP_Call(19); -- [LINE 431]
_OP__Dir__ = OP_Call(20); -- [LINE 432]
_OP__Get__ = OP_Call(21); -- [LINE 433]
_OP__Set__ = OP_Call(22); -- [LINE 434]
_OP__Delete__ = OP_Call(23); -- [LINE 435]
_OP__Slots__ = OP_Call(24); -- [LINE 436]
_OP__Call__ = OP_Call(25); -- [LINE 437]
_OP__Len__ = OP_Call(26); -- [LINE 438]
_OP__Getitem__ = OP_Call(27); -- [LINE 439]
_OP__Setitem__ = OP_Call(28); -- [LINE 440]
_OP__Delitem__ = OP_Call(29); -- [LINE 441]
_OP__Iter__ = OP_Call(30); -- [LINE 442]
_OP__Reversed__ = OP_Call(31); -- [LINE 443]
_OP__Contains__ = OP_Call(32); -- [LINE 444]
_OP__Add__ = OP_Math2(33, 46); -- [LINE 447]
_OP__Sub__ = OP_Math2(34, 47); -- [LINE 448]
_OP__Mul__ = OP_Math2(35, 48); -- [LINE 449]
_OP__Truediv__ = OP_Math2(36, 49); -- [LINE 450]
_OP__Floordiv__ = OP_Math2(37, 50); -- [LINE 451]
_OP__Mod__ = OP_Math2(38, 51); -- [LINE 452]
_OP__Divmod__ = OP_Math2(39, 52); -- [LINE 453]
_OP__Pow__ = OP_Math2_Pow(40, 53); -- [LINE 454]
_OP__Lshift__ = OP_Math2(41, 54); -- [LINE 455]
_OP__Rshift__ = OP_Math2(42, 55); -- [LINE 456]
_OP__And__ = OP_Math2(43, 56); -- [LINE 457]
_OP__Xor__ = OP_Math2(44, 57); -- [LINE 458]
_OP__Or__ = OP_Math2(45, 58); -- [LINE 459]
_OP__Iadd__ = OP_Math3(59, 33, 46); -- [LINE 462]
_OP__Isub__ = OP_Math3(60, 34, 47); -- [LINE 463]
_OP__Imul__ = OP_Math3(61, 35, 48); -- [LINE 464]
_OP__Itruediv__ = OP_Math3(62, 36, 49); -- [LINE 465]
_OP__Ifloordiv__ = OP_Math3(63, 37, 50); -- [LINE 466]
_OP__Imod__ = OP_Math3(64, 38, 51); -- [LINE 467]
_OP__Ipow__ = OP_Math3_Pow(65, 40, 53); -- [LINE 468]
_OP__Ilshift__ = OP_Math3(66, 41, 54); -- [LINE 469]
_OP__Irshift__ = OP_Math3(67, 42, 55); -- [LINE 470]
_OP__Iand__ = OP_Math3(68, 43, 56); -- [LINE 471]
_OP__Ixor__ = OP_Math3(69, 44, 57); -- [LINE 472]
_OP__Ior__ = OP_Math3(70, 45, 58); -- [LINE 473]
_OP__Neg__ = OP_Call(71); -- [LINE 476]
_OP__Pos__ = OP_Call(72); -- [LINE 477]
_OP__Abs__ = OP_Call(73); -- [LINE 478]
_OP__Invert__ = OP_Call(74); -- [LINE 479]
_OP__Complex__ = OP_Call(75); -- [LINE 480]
_OP__Int__ = OP_Call(76); -- [LINE 481]
_OP__Float__ = OP_Call(77); -- [LINE 482]
_OP__Round__ = OP_Call(78); -- [LINE 483]
_OP__Index__ = OP_Call(79); -- [LINE 484]
_OP__Enter__ = OP_Call(80); -- [LINE 485]
_OP__Exit__ = OP_Call(81); -- [LINE 486]
_OP__Lua__ = OP_Call(82); -- [LINE 489]
 -- [LINE 491]
local x = list({int(1), int(2), int(3)}); -- [LINE 494]
local y = int(5); -- [LINE 495]
local z = int(7); -- [LINE 496]
print(x); -- [LINE 498]
print(_OP__Add__(y, z)); -- [LINE 499]
print(X); -- [LINE 501]
