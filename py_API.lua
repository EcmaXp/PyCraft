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
  local _, x;
  for _, x in pairs(args) do -- [LINE 18]
    r = r..x; -- [LINE 19]
  end;
  return r; -- [LINE 21]
end;
lua.len = lua_len; -- [LINE 23]
lua.concat = lua_concat; -- [LINE 24]
local function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 27]
    error('This is not number', 2); -- [LINE 28]
  end;
  return math.floor(num) ~= num; -- [LINE 30]
end;
local function error(msg, level)
  if level == nil then -- [LINE 33]
    level = 1; -- [LINE 34]
  end;
  level = (level + 1); -- [LINE 36]
  lua.error(lua.concat(TAG, ' ', msg), level); -- [LINE 37]
end;
local function require_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 40]
    if value == nil then -- [LINE 41]
      error('SystemError: Not Enough Item'); -- [LINE 42]
    end;
  end;
  return True; -- [LINE 44]
end;
local function nonrequire_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 47]
    if value ~= nil then -- [LINE 48]
      error('SystemError: Not Enough Item'); -- [LINE 49]
    end;
  end;
  return True; -- [LINE 51]
end;
local function metacall(obj, fname, ...)
  local args = {...};
  local mtable = getmetatable(obj); -- [LINE 54]
  local func = rawget(mtable, fname); -- [LINE 55]
  if func == nil then -- [LINE 56]
    error(lua.concat('Method ', fname, ' are not found!'), 1); -- [LINE 57]
  else
    return func(obj, ...); -- [LINE 59]
  end;
end;
local function safemetacall(obj, fname, ...)
  local args = {...};
  local mtable = getmetatable(obj); -- [LINE 62]
  local func = rawget(mtable, fname); -- [LINE 63]
  if func == nil then -- [LINE 64]
    return {false, nil}; -- [LINE 65]
  else
    return {true, func(obj, ...)}; -- [LINE 67]
  end;
end;
function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 70]
    error('This is not number', 2); -- [LINE 71]
  end;
  return math.floor(num) ~= num; -- [LINE 73]
end;
local function is_pyobj(obj)
  local mtable = lua.getmetatable(obj); -- [LINE 76]
  return mtable and rawget(mtable, TAG) == TAG or false; -- [LINE 77]
end;
local function to_pyobj(obj)
  if is_pyobj(obj) then -- [LINE 80]
    return obj; -- [LINE 81]
  else
    return LuaObject(obj); -- [LINE 83]
  end;
end;
local function to_luaobj(obj)
  if is_pyobj(obj) then -- [LINE 97]
    return metacall(obj, '__lua__'); -- [LINE 98]
  else
    return obj; -- [LINE 100]
  end;
end;
local function require_pyobj(...)
  local objs = {...};
  local idx, obj;
  for idx, obj in pairs(objs) do -- [LINE 103]
    if not is_pyobj(obj) then -- [LINE 104]
      error('Require python object.'); -- [LINE 105]
    end;
  end;
  return true; -- [LINE 107]
end;
function repr(obj)
  if is_pyobj(obj) then -- [LINE 111]
    return metacall(to_pyobj(obj), '__repr__'); -- [LINE 112]
  else
    return lua.concat('@(', tostring(obj), ')'); -- [LINE 114]
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
    return metacall(self, '__call__', ...); -- [LINE 122]
  end;
  setfenv(__call, _G)
  function __index(self, key)
    return metacall(self, '__getattribute__', key); -- [LINE 125]
  end;
  setfenv(__index, _G)
  function __newindex(self, key, value)
    return metacall(self, '__setattr__', key, value); -- [LINE 128]
  end;
  setfenv(__newindex, _G)
  function __tostring(self)
    return lua.concat('#(', to_luaobj(repr(self)), ')'); -- [LINE 131]
  end;
  setfenv(__tostring, _G)
  function __new__(cls, ...)
    local args = {...};
    OBJ_ID = (OBJ_ID + 1); -- [LINE 135]
    local instance = {['__id'] = OBJ_ID}; -- [LINE 137]
    lua.setmetatable(instance, cls); -- [LINE 138]
    metacall(instance, '__init__', ...); -- [LINE 139]
    return instance; -- [LINE 141]
  end;
  setfenv(__new__, _G)
  function __getattribute__(self, key)
    local value = rawget(self, key); -- [LINE 144]
    if value ~= nil then -- [LINE 145]
      return value; -- [LINE 146]
    end;
    local mtable = getmetatable(self); -- [LINE 148]
    value = rawget(mtable, key); -- [LINE 149]
    if value ~= nil then -- [LINE 150]
      if lua.type(value) == 'function' then -- [LINE 151]
        return (function(...) return value(self, unpack({...})) end); -- [LINE 152]
      else
        return value; -- [LINE 154]
      end;
    end;
    error(lua.concat("Not found '", key, "' attribute.")); -- [LINE 156]
  end;
  setfenv(__getattribute__, _G)
  function __setattr__(self, key, value)
    rawset(self, key, value); -- [LINE 159]
  end;
  setfenv(__setattr__, _G)
  function __repr__(self)
    local mtable = getmetatable(self); -- [LINE 162]
    return str(concat('<object ', mtable.__name__, ' at ', tostring(self.__id), '>')); -- [LINE 163]
  end;
  setfenv(__repr__, _G)
  return getfenv();
end)(getfenv());
rawset(object, TAG, TAG); -- [LINE 165]
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
    return cls.__new__(cls, ...); -- [LINE 170]
  end;
  setfenv(__call__, _G)
  function __repr__(cls)
    return str(lua.concat("<class '", cls.__name__, "'>")); -- [LINE 173]
  end;
  setfenv(__repr__, _G)
  function mro(cls)
    return cls.__mro__; -- [LINE 176]
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
    if lua.len(args) == 1 then -- [LINE 180]
      return getmetatable(args[1]); -- [LINE 182]
    elseif lua.len(args) == 3 then -- [LINE 183]
    else
      error('Unexcepted arguments.'); -- [LINE 186]
    end;
  end;
  setfenv(__call__, _G)
  return getfenv();
end)(getfenv());
setmetatable(object, type); -- [LINE 188]
setmetatable(type, ptype); -- [LINE 189]
setmetatable(ptype, ptype); -- [LINE 190]
local LuaObject = (function(_G) -- (class LuaObject:object)
  setfenv(1, setmetatable({}, {_G=_G,__index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'LuaObject';
  LuaObject = true; -- [LINE 194]
  function __init__(self, obj)
    local mtable = getmetatable(obj); -- [LINE 198]
    if mtable and rawget(mtable, 'LuaObject') then -- [LINE 199]
      obj = to_luaobj(obj); -- [LINE 200]
    end;
    object.__setattr__(self, 'value', obj); -- [LINE 202]
  end;
  setfenv(__init__, _G)
  function __str__(self)
    return str(metacall(self, '__repr__')); -- [LINE 205]
  end;
  setfenv(__str__, _G)
  function __repr__(self)
    return str(tostring(self.value)); -- [LINE 208]
  end;
  setfenv(__repr__, _G)
  function __lua__(self)
    return self.value; -- [LINE 211]
  end;
  setfenv(__lua__, _G)
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
    self.check_type(obj); -- [LINE 215]
    object.__setattr__(self, 'value', obj); -- [LINE 216]
  end;
  setfenv(__init__, _G)
  function check_type(self, obj)
    if obj[lua.len(obj)] == nil then -- [LINE 219]
    elseif obj[1] == nil then -- [LINE 220]
    elseif obj[0] ~= nil then -- [LINE 221]
    else
      return true; -- [LINE 223]
    end;
    return false; -- [LINE 225]
  end;
  setfenv(check_type, _G)
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
    local ret = {}; -- [LINE 230]
    local idx = 1; -- [LINE 231]
    local sep = ''; -- [LINE 233]
    ret[idx] = '['; -- [LINE 234]
    idx = (idx + 1); -- [LINE 234]
    local k, v;
    for k, v in pairs(self.value) do -- [LINE 235]
      ret[idx] = sep; -- [LINE 236]
      idx = (idx + 1); -- [LINE 236]
      ret[idx] = to_luaobj(repr(v)); -- [LINE 237]
      idx = (idx + 1); -- [LINE 237]
      sep = ', '; -- [LINE 238]
    end;
    ret[idx] = ']'; -- [LINE 240]
    idx = (idx + 1); -- [LINE 240]
    return table.concat(ret); -- [LINE 242]
  end;
  setfenv(__repr__, _G)
  function __setattr__(self, key, value)
    error('Not allowed'); -- [LINE 245]
  end;
  setfenv(__setattr__, _G)
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
    if is_pyobj(value) then -- [LINE 250]
      value = metacall(value, '__str__'); -- [LINE 251]
      value = to_luaobj(value); -- [LINE 252]
    end;
    self.value = value; -- [LINE 254]
  end;
  setfenv(__init__, _G)
  function __str__(self)
    return self; -- [LINE 257]
  end;
  setfenv(__str__, _G)
  function __repr__(self)
    return str(lua.concat("'", self.value, "'")); -- [LINE 260]
  end;
  setfenv(__repr__, _G)
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
    return int((self.value + other.value)); -- [LINE 266]
  end;
  setfenv(__add__, _G)
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
  return getfenv();
end)(getfenv());
setmetatable(dict, type);
function print(...)
  local args = {...};
  local write = lua.io.write; -- [LINE 284]
  local sep = ' '; -- [LINE 285]
  local _, arg;
  for _, arg in pairs(args) do -- [LINE 287]
    write(tostring(to_luaobj(str(arg)))); -- [LINE 288]
    write(sep); -- [LINE 289]
  end;
  write('\n'); -- [LINE 291]
end;
local function OP_Call2(op, ax, bx)
  ax = lua.concat('__', ax, '__'); -- [LINE 294]
  if bx ~= nil then -- [LINE 295]
    bx = lua.concat('__', bx, '__'); -- [LINE 296]
  end;
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 299]
    have, ret = unpack(safemetacall(a, ax, b)); -- [LINE 301]
    lua.print(have, ret); -- [LINE 302]
    if have and ret ~= NotImplemented then -- [LINE 303]
      return ret; -- [LINE 304]
    end;
    if bx ~= nil then -- [LINE 306]
      have, ret = unpack(safemetacall(a, bx, b)); -- [LINE 307]
      if have and ret ~= NotImplemented then -- [LINE 308]
        return ret; -- [LINE 309]
      end;
    end;
    have, ret = unpack(safemetacall(b, ax, a)); -- [LINE 311]
    if have and ret ~= NotImplemented then -- [LINE 312]
      return ret; -- [LINE 313]
    end;
    error(lua.concat("Can't do '", op, "'")); -- [LINE 315]
  end;
  return func; -- [LINE 317]
end;
_OP__Add__ = OP_Call2('+', 'add', 'radd'); -- [LINE 320]
_OP__Sub__ = OP_Call2('-', 'sub', 'rsub'); -- [LINE 321]
local x = list({int(1), int(2), int(3)}); -- [LINE 323]
local y = int(5); -- [LINE 324]
local z = int(7); -- [LINE 325]
print(x); -- [LINE 326]
print(_OP__Add__(y, z)); -- [LINE 327]
