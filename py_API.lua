local _M = getfenv();
if pyscripter then -- [LINE 1]
  exit(__import__('pc').main()); -- [LINE 1]
end;
local __PC_METHODS = {'__new__', '__init__', '__del__', '__repr__', '__str__', '__bytes__', '__format__', '__lt__', '__le__', '__eq__', '__ne__', '__gt__', '__ge__', '__hash__', '__bool__', '__getattr__', '__getattribute__', '__setattr__', '__delattr__', '__dir__', '__get__', '__set__', '__delete__', '__slots__', '__call__', '__len__', '__getitem__', '__setitem__', '__delitem__', '__iter__', '__reversed__', '__contains__', '__add__', '__sub__', '__mul__', '__truediv__', '__floordiv__', '__mod__', '__divmod__', '__pow__', '__lshift__', '__rshift__', '__and__', '__xor__', '__or__', '__radd__', '__rsub__', '__rmul__', '__rtruediv__', '__rfloordiv__', '__rmod__', '__rdivmod__', '__rpow__', '__rlshift__', '__rrshift__', '__rand__', '__rxor__', '__ror__', '__iadd__', '__isub__', '__imul__', '__itruediv__', '__ifloordiv__', '__imod__', '__ipow__', '__ilshift__', '__irshift__', '__iand__', '__ixor__', '__ior__', '__neg__', '__pos__', '__abs__', '__invert__', '__complex__', '__int__', '__float__', '__round__', '__index__', '__enter__', '__exit__'}; -- [LINE 3]
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
local methods = {'__new__', '__init__', '__del__', '__repr__', '__str__', '__bytes__', '__format__', '__lt__', '__le__', '__eq__', '__ne__', '__gt__', '__ge__', '__hash__', '__bool__', '__getattr__', '__getattribute__', '__setattr__', '__delattr__', '__dir__', '__get__', '__set__', '__delete__', '__slots__', '__call__', '__len__', '__getitem__', '__setitem__', '__delitem__', '__iter__', '__reversed__', '__contains__', '__add__', '__sub__', '__mul__', '__truediv__', '__floordiv__', '__mod__', '__divmod__', '__pow__', '__lshift__', '__rshift__', '__and__', '__xor__', '__or__', '__radd__', '__rsub__', '__rmul__', '__rtruediv__', '__rfloordiv__', '__rmod__', '__rdivmod__', '__rpow__', '__rlshift__', '__rrshift__', '__rand__', '__rxor__', '__ror__', '__iadd__', '__isub__', '__imul__', '__itruediv__', '__ifloordiv__', '__imod__', '__ipow__', '__ilshift__', '__irshift__', '__iand__', '__ixor__', '__ior__', '__neg__', '__pos__', '__abs__', '__invert__', '__complex__', '__int__', '__float__', '__round__', '__index__', '__enter__', '__exit__'}; -- [LINE 16]
local function lua_len(obj)
  return #obj; -- [LINE 19]
end;
local function lua_concat(...)
  local args = {...};
  local r = ''; -- [LINE 22]
  local _, x;
  for _, x in pairs(args) do -- [LINE 23]
    r = r..x; -- [LINE 24]
  end;
  return r; -- [LINE 26]
end;
lua.len = lua_len; -- [LINE 28]
lua.concat = lua_concat; -- [LINE 29]
local function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 32]
    error('This is not number', 2); -- [LINE 33]
  end;
  return math.floor(num) ~= num; -- [LINE 35]
end;
local function error(msg, level)
  if level == nil then -- [LINE 38]
    level = 1; -- [LINE 39]
  end;
  level = (level + 1); -- [LINE 41]
  lua.error(lua.concat(TAG, ' ', msg), level); -- [LINE 42]
end;
local function require_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 45]
    if value == nil then -- [LINE 46]
      error('SystemError: Not Enough Item'); -- [LINE 47]
    end;
  end;
  return True; -- [LINE 49]
end;
local function nonrequire_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 52]
    if value ~= nil then -- [LINE 53]
      error('SystemError: Not Enough Item'); -- [LINE 54]
    end;
  end;
  return True; -- [LINE 56]
end;
local function metacall(obj, fname, ...)
  local args = {...};
  local mtable = getmetatable(obj); -- [LINE 59]
  local func = rawget(mtable, fname); -- [LINE 60]
  if func == nil then -- [LINE 61]
    error(lua.concat('Method ', fname, ' are not found!'), 1); -- [LINE 62]
  else
    return func(obj, ...); -- [LINE 64]
  end;
end;
local function safemetacall(obj, fname, ...)
  local args = {...};
  local mtable = getmetatable(obj); -- [LINE 67]
  local func = rawget(mtable, fname); -- [LINE 68]
  if func == nil then -- [LINE 69]
    return {false, nil}; -- [LINE 70]
  else
    return {true, func(obj, ...)}; -- [LINE 72]
  end;
end;
function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 75]
    error('This is not number', 2); -- [LINE 76]
  end;
  return math.floor(num) ~= num; -- [LINE 78]
end;
local function is_pyobj(obj)
  local mtable = lua.getmetatable(obj); -- [LINE 81]
  return mtable and rawget(mtable, TAG) == TAG or false; -- [LINE 82]
end;
local function to_pyobj(obj)
  if is_pyobj(obj) then -- [LINE 85]
    return obj; -- [LINE 86]
  else
    return LuaObject(obj); -- [LINE 88]
  end;
end;
local function to_luaobj(obj)
  if is_pyobj(obj) then -- [LINE 102]
    return metacall(obj, '__lua__'); -- [LINE 103]
  else
    return obj; -- [LINE 105]
  end;
end;
local function require_pyobj(...)
  local objs = {...};
  local idx, obj;
  for idx, obj in pairs(objs) do -- [LINE 108]
    if not is_pyobj(obj) then -- [LINE 109]
      error('Require python object.'); -- [LINE 110]
    end;
  end;
  return true; -- [LINE 112]
end;
function repr(obj)
  if is_pyobj(obj) then -- [LINE 116]
    return _OP__Repr__(obj); -- [LINE 117]
  else
    return lua.concat('@(', tostring(obj), ')'); -- [LINE 119]
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
    return metacall(self, '__call__', ...); -- [LINE 127]
  end;
  setfenv(__call, _G)
  function __index(self, key)
    return metacall(self, '__getattribute__', key); -- [LINE 130]
  end;
  setfenv(__index, _G)
  function __newindex(self, key, value)
    return metacall(self, '__setattr__', key, value); -- [LINE 133]
  end;
  setfenv(__newindex, _G)
  function __tostring(self)
    return lua.concat('#(', to_luaobj(repr(self)), ')'); -- [LINE 136]
  end;
  setfenv(__tostring, _G)
  function __new__(cls, ...)
    local args = {...};
    OBJ_ID = (OBJ_ID + 1); -- [LINE 140]
    local instance = {['__id'] = OBJ_ID}; -- [LINE 142]
    lua.setmetatable(instance, cls); -- [LINE 143]
    metacall(instance, '__init__', ...); -- [LINE 144]
    return instance; -- [LINE 146]
  end;
  setfenv(__new__, _G)
  function __getattribute__(self, key)
    local value = rawget(self, key); -- [LINE 149]
    if value ~= nil then -- [LINE 150]
      return value; -- [LINE 151]
    end;
    local mtable = getmetatable(self); -- [LINE 153]
    value = rawget(mtable, key); -- [LINE 154]
    if value ~= nil then -- [LINE 155]
      if lua.type(value) == 'function' then -- [LINE 156]
        return (function(...) return value(self, unpack({...})) end); -- [LINE 157]
      else
        return value; -- [LINE 159]
      end;
    end;
    error(lua.concat("Not found '", key, "' attribute.")); -- [LINE 161]
  end;
  setfenv(__getattribute__, _G)
  function __setattr__(self, key, value)
    rawset(self, key, value); -- [LINE 164]
  end;
  setfenv(__setattr__, _G)
  function __repr__(self)
    local mtable = getmetatable(self); -- [LINE 167]
    return str(concat('<object ', mtable.__name__, ' at ', tostring(self.__id), '>')); -- [LINE 168]
  end;
  setfenv(__repr__, _G)
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
rawset(object, TAG, TAG); -- [LINE 170]
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
    return cls.__new__(cls, ...); -- [LINE 175]
  end;
  setfenv(__call__, _G)
  function __repr__(cls)
    return str(lua.concat("<class '", cls.__name__, "'>")); -- [LINE 178]
  end;
  setfenv(__repr__, _G)
  function mro(cls)
    return cls.__mro__; -- [LINE 181]
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
  __name__ = 'type'; -- [LINE 184]
  function __setattr__(self, name)
    error('Not allowed setattr for builtins type.'); -- [LINE 187]
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
    if lua.len(args) == 1 then -- [LINE 191]
      return getmetatable(args[1]); -- [LINE 193]
    elseif lua.len(args) == 3 then -- [LINE 194]
    else
      error('Unexcepted arguments.'); -- [LINE 197]
    end;
  end;
  setfenv(__call__, _G)
  DO_SUPPORT_PCEX(getfenv());
  return getfenv();
end)(getfenv());
setmetatable(object, builtins_type); -- [LINE 199]
setmetatable(type, ptype); -- [LINE 200]
setmetatable(ptype, ptype); -- [LINE 201]
local LuaObject = (function(_G) -- (class LuaObject:object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'LuaObject';
  LuaObject = true; -- [LINE 205]
  function __init__(self, obj)
    local mtable = getmetatable(obj); -- [LINE 209]
    if mtable and rawget(mtable, 'LuaObject') then -- [LINE 210]
      obj = to_luaobj(obj); -- [LINE 211]
    end;
    object.__setattr__(self, 'value', obj); -- [LINE 213]
  end;
  setfenv(__init__, _G)
  function __str__(self)
    return str(metacall(self, '__repr__')); -- [LINE 216]
  end;
  setfenv(__str__, _G)
  function __repr__(self)
    return str(tostring(self.value)); -- [LINE 219]
  end;
  setfenv(__repr__, _G)
  function __lua__(self)
    return self.value; -- [LINE 222]
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
    self.check_type(obj); -- [LINE 226]
    object.__setattr__(self, 'value', obj); -- [LINE 227]
  end;
  setfenv(__init__, _G)
  function check_type(self, obj)
    if obj[lua.len(obj)] == nil then -- [LINE 230]
    elseif obj[1] == nil then -- [LINE 231]
    elseif obj[0] ~= nil then -- [LINE 232]
    else
      return true; -- [LINE 234]
    end;
    return false; -- [LINE 236]
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
    local ret = {}; -- [LINE 241]
    local idx = 1; -- [LINE 242]
    local sep = ''; -- [LINE 244]
    ret[idx] = '['; -- [LINE 245]
    idx = (idx + 1); -- [LINE 245]
    local k, v;
    for k, v in pairs(self.value) do -- [LINE 246]
      ret[idx] = sep; -- [LINE 247]
      idx = (idx + 1); -- [LINE 247]
      ret[idx] = to_luaobj(repr(v)); -- [LINE 248]
      idx = (idx + 1); -- [LINE 248]
      sep = ', '; -- [LINE 249]
    end;
    ret[idx] = ']'; -- [LINE 251]
    idx = (idx + 1); -- [LINE 251]
    return table.concat(ret); -- [LINE 253]
  end;
  setfenv(__repr__, _G)
  function __setattr__(self, key, value)
    error('Not allowed'); -- [LINE 256]
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
    if is_pyobj(value) then -- [LINE 261]
      value = metacall(value, '__str__'); -- [LINE 262]
      value = to_luaobj(value); -- [LINE 263]
    end;
    self.value = value; -- [LINE 265]
  end;
  setfenv(__init__, _G)
  function __str__(self)
    return self; -- [LINE 268]
  end;
  setfenv(__str__, _G)
  function __repr__(self)
    return str(lua.concat("'", self.value, "'")); -- [LINE 271]
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
    return int((self.value + other.value)); -- [LINE 277]
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
  local write = lua.io.write; -- [LINE 295]
  local sep = ' '; -- [LINE 296]
  local _, arg;
  for _, arg in pairs(args) do -- [LINE 298]
    write(tostring(to_luaobj(str(arg)))); -- [LINE 299]
    write(sep); -- [LINE 300]
  end;
  write('\n'); -- [LINE 302]
end;
local function OP_Call(x)
  local function func(o)
    assert(require_pyobj(o)); -- [LINE 306]
    return rawget(getmetatable(o), __PCEX__)[x](o); -- [LINE 307]
  end;
  return func; -- [LINE 308]
end;
local function OP_Call2(ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 312]
    local am = rawget(getmetatable(a), __PCEX__); -- [LINE 314]
    local bm = rawget(getmetatable(b), __PCEX__); -- [LINE 315]
    local f = am[ax]; -- [LINE 317]
    if f then -- [LINE 318]
      local ret = f(a, b); -- [LINE 319]
      if ret ~= NotImplemented then -- [LINE 320]
        return ret; -- [LINE 321]
      end;
    end;
    f = bm[bx]; -- [LINE 323]
    if f then -- [LINE 324]
      ret = f(b, a); -- [LINE 325]
      if ret ~= NotImplemented then -- [LINE 326]
        return ret; -- [LINE 327]
      end;
    end;
    f = bm[ax]; -- [LINE 329]
    if f then -- [LINE 330]
      ret = f(b, a); -- [LINE 331]
      if ret ~= NotImplemented then -- [LINE 332]
        return ret; -- [LINE 333]
      end;
    end;
    error(lua.concat("Can't do '", ax, "'")); -- [LINE 335]
  end;
  return func; -- [LINE 337]
end;
_OP__Add__ = OP_Call2(33, 46); -- [LINE 340]
_OP__Sub__ = OP_Call2(34, 47); -- [LINE 341]
_OP__Repr__ = OP_Call(4); -- [LINE 342]
local x = list({int(1), int(2), int(3)}); -- [LINE 344]
local y = int(5); -- [LINE 345]
local z = int(7); -- [LINE 346]
print(x); -- [LINE 347]
print(_OP__Add__(y, z)); -- [LINE 348]
lua.print(list.__PCEX__[4]); -- [LINE 349]
