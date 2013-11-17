local _M = getfenv();
if pyscripter then -- [LINE 1]
  exit(__import__('pc').main()); -- [LINE 1]
end;
lua = {}; -- [LINE 6]
local key, value;
for key, value in pairs(_G) do -- [LINE 7]
  lua[key] = value; -- [LINE 8]
end;
local TAG = '[PY]'; -- [LINE 10]
local OBJ_ID = 0; -- [LINE 11]
local function lua_len(obj)
  return #obj; -- [LINE 14]
end;
local function lua_concat(...)
  local args = {...};
  local r = ''; -- [LINE 17]
  local _, str;
  for _, str in pairs(args) do -- [LINE 18]
    r = r..str; -- [LINE 19]
  end;
  return r; -- [LINE 21]
end;
lua.len = lua_len; -- [LINE 23]
lua.concat = lua_concat; -- [LINE 24]
local function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 43]
    error('This is not number', 2); -- [LINE 44]
  end;
  return math.floor(num) ~= num; -- [LINE 46]
end;
local function error(msg, level)
  if level == nil then -- [LINE 49]
    local level = 1; -- [LINE 50]
  end;
  level = (level + 1); -- [LINE 52]
  lua.error(lua.concat(TAG, ' ', msg), level); -- [LINE 53]
end;
local function require_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 56]
    if value == nil then -- [LINE 57]
      error('SystemError: Not Enough Item'); -- [LINE 58]
    end;
  end;
  return True; -- [LINE 60]
end;
local function nonrequire_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 63]
    if value ~= nil then -- [LINE 64]
      error('SystemError: Not Enough Item'); -- [LINE 65]
    end;
  end;
  return True; -- [LINE 67]
end;
local function metacall(obj, fname, ...)
  local args = {...};
  local mtable = getmetatable(obj); -- [LINE 70]
  local value = rawget(mtable, fname); -- [LINE 71]
  return value(obj, ...); -- [LINE 72]
end;
local function repr(obj)
  return metacall(to_pyobj(obj), '__repr__'); -- [LINE 75]
end;
object = (function(_G) -- (class object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  __name__ = 'object';
  function __init__(self)
  end;
  setfenv(__init__, _G)
  function __call(self, ...)
    local args = {...};
    return metacall(self, '__call__', ...); -- [LINE 83]
  end;
  setfenv(__call, _G)
  function __index(self, key)
    return metacall(self, '__getattribute__', key); -- [LINE 86]
  end;
  setfenv(__index, _G)
  function __newindex(self, key, value)
    return metacall(self, '__setattr__', key, value); -- [LINE 89]
  end;
  setfenv(__newindex, _G)
  function __tostring(self)
    return concat('@', to_luaobj(repr(self))); -- [LINE 92]
  end;
  setfenv(__tostring, _G)
  function __new__(cls, ...)
    local args = {...};
    OBJ_ID = (OBJ_ID + 1); -- [LINE 96]
    local instance = {['__id'] = OBJ_ID}; -- [LINE 98]
    lua.setmetatable(instance, cls); -- [LINE 99]
    metacall(instance, '__init__', ...); -- [LINE 100]
    return instance; -- [LINE 102]
  end;
  setfenv(__new__, _G)
  function __getattribute__(self, key)
    local value = rawget(self, key); -- [LINE 105]
    if value ~= nil then -- [LINE 106]
      return value; -- [LINE 107]
    end;
    local mtable = getmetatable(self); -- [LINE 109]
    value = rawget(mtable, key); -- [LINE 110]
    if value ~= nil then -- [LINE 111]
      if lua.type(value) == 'function' then -- [LINE 112]
        return (function(...) return value(self, unpack({...})) end); -- [LINE 113]
      else
        return value; -- [LINE 115]
      end;
    end;
    error('?'); -- [LINE 117]
  end;
  setfenv(__getattribute__, _G)
  function __setattr__(self, key, value)
    rawset(self, key, value); -- [LINE 120]
  end;
  setfenv(__setattr__, _G)
  function __repr__(self)
    local mtable = getmetatable(self); -- [LINE 123]
    return str(concat('<object ', mtable.__name__, ' at ', tostring(self.__id), '>')); -- [LINE 124]
  end;
  setfenv(__repr__, _G)
  return getfenv();
end)(getfenv());
rawset(object, TAG, TAG); -- [LINE 126]
local type = (function(_G) -- (class type:object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'type';
  function __call__(cls, ...)
    local args = {...};
    return cls.__new__(cls, ...); -- [LINE 130]
  end;
  setfenv(__call__, _G)
  function __repr__(cls)
    return str(lua.concat("<class '", cls.__name__, "'>")); -- [LINE 133]
  end;
  setfenv(__repr__, _G)
  function mro(cls)
    return cls.__mro__; -- [LINE 136]
  end;
  setfenv(mro, _G)
  return getfenv();
end)(getfenv());
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
    if lua.len(args) == 1 then -- [LINE 140]
      return getmetatable(args[1]); -- [LINE 142]
    elseif lua.len(args) == 3 then -- [LINE 143]
    else
      error('Unexcepted arguments.'); -- [LINE 146]
    end;
  end;
  setfenv(__call__, _G)
  return getfenv();
end)(getfenv());
setmetatable(object, type); -- [LINE 148]
setmetatable(type, ptype); -- [LINE 149]
setmetatable(ptype, ptype); -- [LINE 150]
local LuaObject = (function(_G) -- (class LuaObject:object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'LuaObject';
  function __init__(self, obj)
    self.value = obj; -- [LINE 154]
  end;
  setfenv(__init__, _G)
  function __repr__(self)
    return tostring(self.value); -- [LINE 157]
  end;
  setfenv(__repr__, _G)
  function __lua__(self)
    return self.value; -- [LINE 160]
  end;
  setfenv(__lua__, _G)
  return getfenv();
end)(getfenv());
setmetatable(LuaObject, type);
local str = (function(_G) -- (class str:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'str';
  function __str__(self)
    return self; -- [LINE 164]
  end;
  setfenv(__str__, _G)
  function __repr__(self)
    return lua.concat("'", self.value, "'"); -- [LINE 167]
  end;
  setfenv(__repr__, _G)
  return getfenv();
end)(getfenv());
setmetatable(str, type);
local int = (function(_G) -- (class int:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'int';
  return getfenv();
end)(getfenv());
setmetatable(int, type);
function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 173]
    error('This is not number', 2); -- [LINE 174]
  end;
  return math.floor(num) ~= num; -- [LINE 176]
end;
local function is_pyobj(obj)
  local mtable = lua.getmetatable(obj); -- [LINE 179]
  return mtable and rawget(mtable, TAG) == TAG; -- [LINE 180]
end;
local function to_pyobj(obj)
  if is_pyobj(obj) then -- [LINE 183]
    return obj; -- [LINE 184]
  else
    local objtype = lua.type(obj); -- [LINE 186]
    if objtype == 'number' then -- [LINE 187]
      if (notis_float(obj)) then -- [LINE 188]
        return int(obj); -- [LINE 189]
      else
        return float(obj); -- [LINE 191]
      end;
    elseif objtype == 'string' then -- [LINE 192]
      return str(obj); -- [LINE 193]
    else
      return LuaObject(obj); -- [LINE 195]
    end;
  end;
end;
local function to_luaobj(obj)
  if is_pyobj(obj) then -- [LINE 198]
    return obj.__lua__(); -- [LINE 199]
  else
    return obj; -- [LINE 201]
  end;
end;
local function require_pyobj(...)
  local objs = {...};
  local idx, obj;
  for idx, obj in pairs(objs) do -- [LINE 204]
    if (notis_pyobj(obj)) then -- [LINE 205]
      error('Require python object.'); -- [LINE 206]
    end;
  end;
  return false; -- [LINE 208]
end;
function repr(obj)
  local obj = to_pyobj(obj); -- [LINE 221]
  return metacall(obj, '__repr__'); -- [LINE 222]
end;
local function print(...)
  local args = {...};
  local write = lua.io.write; -- [LINE 225]
  local sep = ' '; -- [LINE 226]
  local _, arg;
  for _, arg in pairs(args) do -- [LINE 228]
    write(tostring(to_luaobj(str(arg)))); -- [LINE 229]
    write(sep); -- [LINE 230]
  end;
  write('\n'); -- [LINE 232]
end;
local function _OP__Add__(a, b)
  assert(require_pyobj(a, b)); -- [LINE 235]
  local ret = metacall(a, '__add__', b); -- [LINE 237]
  if ret ~= NotImplemented then -- [LINE 238]
    return ret; -- [LINE 239]
  end;
  ret = b.__radd__(a); -- [LINE 241]
  if ret ~= NotImplemented then -- [LINE 242]
    return ret; -- [LINE 243]
  end;
  ret = b.__add__(a); -- [LINE 245]
  if ret ~= NotImplemented then -- [LINE 246]
    return ret; -- [LINE 247]
  end;
  fail_op(); -- [LINE 249]
end;
print(repr('hello')); -- [LINE 251]
