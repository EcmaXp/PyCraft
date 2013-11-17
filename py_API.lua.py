local function LUA_CODE(code)
  return True; -- [LINE 3]
end;
if false then
  exec('import pc; pc.main(); exit()'); -- [LINE 4]
end;
lua = {};
local key, value;
for key, value in pairs(_G) do
  lua[key] = value;
end;
local TAG = '[PY]';
local OBJ_ID = 0;
local function lua_len(obj)
  return #obj; -- [LINE 17]
end;
local function lua_concat(a, b, ...)
  local args = {...};
  local r = a..b;
  if len(args) > 0 then
    local _, arg;
    for _, arg in pairs(args) do
      r = r..arg;
    end;
  end;
  return r; -- [LINE 25]
end;
lua.len = lua_len;
lua.concat = lua_concat;
local function is_float(num)
  if lua.type(num) ~= 'number' then
    error('This is not number', 2); -- [LINE 48]
  end;
  return math.floor(num) ~= num; -- [LINE 50]
end;
local function error(msg, level)
  if level == nil then
    local level = 1;
  end;
  level = (level + 1);
  lua.error(concat(TAG, ' ', msg), level); -- [LINE 57]
end;
local function require_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do
    if value == nil then
      error('SystemError: Not Enough Item'); -- [LINE 62]
    end;
  end;
  return True; -- [LINE 64]
end;
local function nonrequire_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do
    if value ~= nil then
      error('SystemError: Not Enough Item'); -- [LINE 69]
    end;
  end;
  return True; -- [LINE 71]
end;
local function metacall(obj, fname, ...)
  local args = {...};
  local mtable = getmetatable(obj);
  local value = rawget(mtable, fname);
  status, result = pcall(value, obj, ...);
  if (notstatus) then
    error(result, 2); -- [LINE 79]
  else
    return result; -- [LINE 81]
  end;
end;
object = (function(_G) -- (class object)
  setfenv(1, setmetatable({}, {_G=_G, __index=_G}));
  __name__ = 'object';
  function __init__(self)
  end;
  function __call(self, ...)
    local args = {...};
    return metacall(self, '__call__', ...); -- [LINE 89]
  end;
  function __get(self, key)
    return metacall(self, '__getattribute__', key); -- [LINE 92]
  end;
  function __set(self, key, value)
    return metacall(self, '__setattr__', key, value); -- [LINE 95]
  end;
  function __tostring(self)
    return concat('@', to_lua(repr(self))); -- [LINE 98]
  end;
  function __new__(cls, ...)
    local args = {...};
    OBJ_ID = (OBJ_ID + 1);
    local instance = {['__id'] = OBJ_ID};
    setmetatable(instance, cls); -- [LINE 105]
    metacall(instance, '__init__', ...); -- [LINE 106]
    return instance; -- [LINE 108]
  end;
  function __getattribute__(self, key)
    local value = rawget(self, key);
    if value ~= nil then
      return value; -- [LINE 113]
    end;
    local mtable = getmetatable(self);
    value = rawget(mtable, key);
    if value ~= nil then
      if lua.type(value) == 'function' then
        return (function(...) return value(self, unpack({...})) end); -- [LINE 119]
      else
        return value; -- [LINE 121]
      end;
    end;
    error('?'); -- [LINE 123]
  end;
  function __setattr__(self, key, value)
    rawset(self, key, value); -- [LINE 126]
  end;
  function __repr__(self)
    local mtable = getmetatable(self);
    return str(concat('<object ', mtable.__name__, ' at ', tostring(self.__id), '>')); -- [LINE 130]
  end;
  return getfenv();
end)(getfenv());
rawset(object, TAG, TAG); -- [LINE 132]
local type = (function(_G) -- (class type:object)
  setfenv(1, setmetatable({}, {_G=_G, __index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'type';
  function __call__(cls, ...)
    local args = {...};
    return cls.__new__(cls, ...); -- [LINE 136]
  end;
  function __repr__(cls)
    return str(concat("<class '", cls.__name__, "'>")); -- [LINE 139]
  end;
  function mro(cls)
    return cls.__mro__; -- [LINE 142]
  end;
  return getfenv();
end)(getfenv());
local ptype = (function(_G) -- (class ptype:type)
  setfenv(1, setmetatable({}, {_G=_G, __index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({type}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'ptype';
  function __call__(cls, ...)
    local args = {...};
    if lua.len(args) == 1 then
      require_pyobj(args[1]); -- [LINE 147]
      return getmetatable(args[1]); -- [LINE 148]
    elseif lua.len(args) == 3 then
    else
      error('Unexcepted arguments.'); -- [LINE 152]
    end;
  end;
  return getfenv();
end)(getfenv());
setmetatable(object, type); -- [LINE 154]
setmetatable(type, ptype); -- [LINE 155]
setmetatable(ptype, ptype); -- [LINE 156]
local LuaObject = (function(_G) -- (class LuaObject:object)
  setfenv(1, setmetatable({}, {_G=_G, __index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'LuaObject';
  function __init__(self, obj)
    self.value = obj;
  end;
  function __repr__(self)
    return tostring(self.value); -- [LINE 163]
  end;
  return getfenv();
end)(getfenv());
setmetatable(LuaObject, type);
local str = (function(_G) -- (class str:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G, __index=_G}));
  (function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(getfenv());
  __name__ = 'str';
  function __str__(self)
    return self; -- [LINE 167]
  end;
  function __repr__(self)
    return lua.concat("'", self.value, "'"); -- [LINE 170]
  end;
  return getfenv();
end)(getfenv());
setmetatable(str, type);
local int = (function(_G) -- (class int:LuaObject)
  setfenv(1, setmetatable({}, {_G=_G, __index=_G}));
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
  if lua.type(num) ~= 'number' then
    error('This is not number', 2); -- [LINE 177]
  end;
  return math.floor(num) ~= num; -- [LINE 179]
end;
local function is_pyobj(obj)
  local mtable = lua.getmetatable(obj);
  return mtable and rawget(obj, TAG) == TAG; -- [LINE 183]
end;
local function to_pyobj(obj)
  if is_pyobj(obj) then
    return obj; -- [LINE 187]
  else
    local objtype = lua.type(obj);
    if objtype == 'number' then
      if (notis_float(obj)) then
        return int(obj); -- [LINE 192]
      else
        return float(obj); -- [LINE 194]
      end;
    elseif objtype == 'string' then
      return str(obj); -- [LINE 196]
    else
      return LuaObject(obj); -- [LINE 198]
    end;
  end;
end;
local function to_luaobj(obj)
  if is_pyobj(obj) then
    return obj.__lua__(); -- [LINE 202]
  else
    return obj; -- [LINE 204]
  end;
end;
local function require_pyobj(...)
  local objs = {...};
  local idx, obj;
  for idx, obj in pairs(objs) do
    if (notis_pyobj(obj)) then
      error('Require python object.'); -- [LINE 209]
    end;
  end;
  return false; -- [LINE 211]
end;
local function repr(obj)
  local obj = to_pyobj(obj);
  return metacall(obj, '__repr__'); -- [LINE 225]
end;
local function print(...)
  local args = {...};
  local write = lua.io.write;
  local sep = ' ';
  local _, arg;
  for _, arg in pairs(args) do
    write(to_luaobj(str(arg))); -- [LINE 232]
    write(sep); -- [LINE 233]
  end;
  write('\n'); -- [LINE 235]
end;
local function _OP__Add__(a, b)
  assert(require_pyobj(a, b)); -- [LINE 238]
  local ret = metacall(a, '__add__', b);
  if ret ~= NotImplemented then
    return ret; -- [LINE 242]
  end;
  ret = b.__radd__(a);
  if ret ~= NotImplemented then
    return ret; -- [LINE 246]
  end;
  ret = b.__add__(a);
  if ret ~= NotImplemented then
    return ret; -- [LINE 250]
  end;
  fail_op(); -- [LINE 252]
end;
print('hello'); -- [LINE 254]
