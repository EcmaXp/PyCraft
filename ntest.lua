TAG = '[PY]'
rawtype = type

local function tcopy(t)
  local t2 = {}
  for k,v in pairs(t) do
    print(k, v)
    t2[k] = v
  end
  return t2
end

function isinstance(object, target)
  getmetatable(object)

end

classmethod = 1

function call(parent, func, ...)
  local tArgs = {...}
  if rawget(func, "__calltype") == classmethod then
    table.insert(tArgs, 1, parent)
  end
  
  if isinstance(tArgs[#tArgs], None) then
  
  end
end

type = {
  __name__ = "type",
  type = "test",
  __call = function(self, ...)
    instance = {__id = 0}
    setmetatable(instance, object)
    return instance
  end,
  __tostring = function(self)
    return "<class '"..self.__name__.."'>"
  end
}
_type = tcopy(type)
_type.__call = function (self, ...)
  if self == type then
    print(unpack({...}))
  end
  
  return type
end
setmetatable(type, _type)

object = {
  __name__ = "object",
  __call = function (self, ...)
    
  end,
  __tostring = function (self)
    return "<object '"..getmetatable(self).__name__.."' at "..self.__id..">"
  end,
  __eq = function ()
    
  end
}
setmetatable(object, type)

print(type(type), '.')
print(object()(), "?!")
print(rawtype(object()))
