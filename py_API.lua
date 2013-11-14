local TAG = '[PY]'
local rawtype = type
local OBJ_ID = 0

local function tcopy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end
lua = tcopy(_G)

local function textend(t1, t2)
  for k,v in pairs(t2) do
    t1[k] = v
  end
  return t1
end

local function tsub(a, b)
  return textend(tcopy(a), b)
end

local function is_float(num)
  if rawtype(num) == "number" then
    return math.floor(num) ~= num
  end

  error("This is not number", 2)
end

function is_pyobj(obj)
  local mtable = getmetatable(obj)
  return mtable and rawget(mtable, "___py___") == TAG
end


function to_pyobj(obj)
  if is_pyobj(obj) then
    return obj
  else
    local objtype = rawtype(obj)
    if objtype == "number" then
      if not is_float(obj) then
        return int(obj)
      else
        return float(obj)
      end
    elseif objtype == "string" then
      return str(obj)
    elseif objtype == "function" then
      return builtin_function_or_method(obj)
    end

    error("type '"..objtype.."' are not supported.")
  end
end

function to_luaobj(obj)
  local mtable = getmetatable(obj)
  if is_pyobj(obj) then
    return obj.__lua__()
  else
    return obj
  end
end

function isinstance(obj, targets)
  local mtable
  if not is_pyobj(obj) then
    return false
  else
    mtable = getmetatable(obj)
    for supercls in mtable.mro() do
      if supercls == targets then
        return true
      end
    end
  end

  return false
end

--[[
{'ArithmeticError': <class 'ArithmeticError'>,
 'AssertionError': <class 'AssertionError'>,
 'AttributeError': <class 'AttributeError'>,
 'BaseException': <class 'BaseException'>,
 'BlockingIOError': <class 'BlockingIOError'>,
 'BrokenPipeError': <class 'BrokenPipeError'>,
 'BufferError': <class 'BufferError'>,
 'BytesWarning': <class 'BytesWarning'>,
 'ChildProcessError': <class 'ChildProcessError'>,
 'ConnectionAbortedError': <class 'ConnectionAbortedError'>,
 'ConnectionError': <class 'ConnectionError'>,
 'ConnectionRefusedError': <class 'ConnectionRefusedError'>,
 'ConnectionResetError': <class 'ConnectionResetError'>,
 'DeprecationWarning': <class 'DeprecationWarning'>,
 'EOFError': <class 'EOFError'>,
 'Ellipsis': Ellipsis,
 'EnvironmentError': <class 'OSError'>,
 'Exception': <class 'Exception'>,
 'False': False,
 'FileExistsError': <class 'FileExistsError'>,
 'FileNotFoundError': <class 'FileNotFoundError'>,
 'FloatingPointError': <class 'FloatingPointError'>,
 'FutureWarning': <class 'FutureWarning'>,
 'GeneratorExit': <class 'GeneratorExit'>,
 'IOError': <class 'OSError'>,
 'ImportError': <class 'ImportError'>,
 'ImportWarning': <class 'ImportWarning'>,
 'IndentationError': <class 'IndentationError'>,
 'IndexError': <class 'IndexError'>,
 'InterruptedError': <class 'InterruptedError'>,
 'IsADirectoryError': <class 'IsADirectoryError'>,
 'KeyError': <class 'KeyError'>,
 'KeyboardInterrupt': <class 'KeyboardInterrupt'>,
 'LookupError': <class 'LookupError'>,
 'MemoryError': <class 'MemoryError'>,
 'NameError': <class 'NameError'>,
 'None': None,
 'NotADirectoryError': <class 'NotADirectoryError'>,
 'NotImplemented': NotImplemented,
 'NotImplementedError': <class 'NotImplementedError'>,
 'OSError': <class 'OSError'>,
 'OverflowError': <class 'OverflowError'>,
 'PendingDeprecationWarning': <class 'PendingDeprecationWarning'>,
 'PermissionError': <class 'PermissionError'>,
 'ProcessLookupError': <class 'ProcessLookupError'>,
 'ReferenceError': <class 'ReferenceError'>,
 'ResourceWarning': <class 'ResourceWarning'>,
 'RuntimeError': <class 'RuntimeError'>,
 'RuntimeWarning': <class 'RuntimeWarning'>,
 'StopIteration': <class 'StopIteration'>,
 'SyntaxError': <class 'SyntaxError'>,
 'SyntaxWarning': <class 'SyntaxWarning'>,
 'SystemError': <class 'SystemError'>,
 'SystemExit': <class 'SystemExit'>,
 'TabError': <class 'TabError'>,
 'TimeoutError': <class 'TimeoutError'>,
 'True': True,
 'TypeError': <class 'TypeError'>,
 'UnboundLocalError': <class 'UnboundLocalError'>,
 'UnicodeDecodeError': <class 'UnicodeDecodeError'>,
 'UnicodeEncodeError': <class 'UnicodeEncodeError'>,
 'UnicodeError': <class 'UnicodeError'>,
 'UnicodeTranslateError': <class 'UnicodeTranslateError'>,
 'UnicodeWarning': <class 'UnicodeWarning'>,
 'UserWarning': <class 'UserWarning'>,
 'ValueError': <class 'ValueError'>,
 'Warning': <class 'Warning'>,
 'WindowsError': <class 'OSError'>,
 'ZeroDivisionError': <class 'ZeroDivisionError'>,
 '_': <Recursion on dict with id=30298560>,
 '__build_class__': <built-in function __build_class__>,
 '__debug__': True,
 '__doc__': "Built-in functions, exceptions, and other objects.\n\nNoteworthy: None is the `nil' object; Ellipsis represents `...' in slices.",
 '__import__': <built-in function __import__>,
 '__name__': 'builtins',
 '__package__': None,
 'abs': <built-in function abs>,
 'all': <built-in function all>,
 'any': <built-in function any>,
 'ascii': <built-in function ascii>,
 'bin': <built-in function bin>,
 'bool': <class 'bool'>,
 'bytearray': <class 'bytearray'>,
 'bytes': <class 'bytes'>,
 'callable': <built-in function callable>,
 'chr': <built-in function chr>,
 'classmethod': <class 'classmethod'>,
 'compile': <built-in function compile>,
 'complex': <class 'complex'>,
 'copyright': copyright,
 'delattr': <built-in function delattr>,
 'dict': <class 'dict'>,
 'dir': <built-in function dir>,
 'divmod': <built-in function divmod>,
 'enumerate': <class 'enumerate'>,
 'eval': <built-in function eval>,
 'exec': <built-in function exec>,
 'exit': Use exit() or Ctrl-Z plus Return to exit,
 'filter': <class 'filter'>,
 'float': <class 'float'>,
 'format': <built-in function format>,
 'frozenset': <class 'frozenset'>,
 'getattr': <built-in function getattr>,
 'globals': <built-in function globals>,
 'hasattr': <built-in function hasattr>,
 'hash': <built-in function hash>,
 'help': Type help() for interactive help, or help(object) for help about object.,
 'hex': <built-in function hex>,
 'id': <built-in function id>,
 'input': <bound method RemotePythonInterpreter.Win32RawInput of <__main__.RemotePythonInterpreter object at 0x02B30670>>,
 'int': <class 'int'>,
 'isinstance': <built-in function isinstance>,
 'issubclass': <built-in function issubclass>,
 'iter': <built-in function iter>,
 'len': <built-in function len>,
 'license': Type license() to see the full license text,
 'list': <class 'list'>,
 'locals': <built-in function locals>,
 'map': <class 'map'>,
 'max': <built-in function max>,
 'memoryview': <class 'memoryview'>,
 'min': <built-in function min>,
 'next': <built-in function next>,
 'object': <class 'object'>,
 'oct': <built-in function oct>,
 'open': <built-in function open>,
 'ord': <built-in function ord>,
 'pow': <built-in function pow>,
 'print': <built-in function print>,
 'property': <class 'property'>,
 'quit': Use quit() or Ctrl-Z plus Return to exit,
 'range': <class 'range'>,
 'repr': <built-in function repr>,
 'reversed': <class 'reversed'>,
 'round': <built-in function round>,
 'set': <class 'set'>,
 'setattr': <built-in function setattr>,
 'slice': <class 'slice'>,
 'sorted': <built-in function sorted>,
 'staticmethod': <class 'staticmethod'>,
 'str': <class 'str'>,
 'sum': <built-in function sum>,
 'super': <class 'super'>,
 'tuple': <class 'tuple'>,
 'type': <class 'type'>,
 'vars': <built-in function vars>,
 'zip': <class 'zip'>}
--]]

--[[
local registry = {
  type = {}
}

setmetatable(registry.type, {__mode="k"})
--]]

function parse_call(func, ...)
  local tArgs = {...}
  if isinstance(tArgs[#tArgs], None) then

  end
end

local function check_pyobj(mtable, obj)
  if rawget(mtable, "___py___") ~= TAG then
    error("obj is not python object.")
  end
end

function raise(obj)

end

function repr(obj)
  return to_pyobj(obj).__repr__()
end

function metacall(obj, fname, ...)
  local value, mtable, status, result

  mtable = getmetatable(obj)
  check_pyobj(mtable)

  value = rawget(mtable, fname)
  status, result = pcall(value, obj, ...)
  if not status then error(result, 2) else return result end
end

function rawmetacall(mtable, obj, fname, ...)
  local value, status, result
  check_pyobj(mtable)

  value = rawget(mtable, fname)
  status, result = pcall(value, obj, ...)
  if not status then error(result, 2) else return result end
end

function getattr(obj, key, default)
  local value, mtable

  mtable = getmetatable(obj)
  value = rawmetacall(mtable, obj, "__getattribute__", key)
  if value ~= nil then return value end

  if mtable.__getattr__ then
    value = rawmetacall(mtable, obj, "__getattr__", key)
    if value ~= nil then return value end
  end

  return default
end

function setattr(obj, key, value)
  metacall(obj, "__setattr__", key, value)
end

function hasattr(obj, key)
  return metacall(obj, "__hasattr__", key)
end

function delattr(obj, key)
  return metacall(obj, "__delattr__", key)
end

function isinstance(object, target)
  getmetatable(object)

end

local function raw_compare(a, b, func)
  local am, bm, status, result
  am = getmetatable(a)
  bm = getmetatable(b)
  setmetatable(a, nil)
  setmetatable(b, nil)

  status, result = pcall(func)

  setmetatable(a, am)
  setmetatable(b, bm)
  if not status then error(result) else return result end
end

local function define_class(meta, obj, ...)
  local cls, mro
  cls = {}
  mro = {}

  assert(obj.__name__)

  args = {...}
  for key, value in pairs(args) do
    textend(cls, value)
    table.insert(mro, cls)
  end

  cls.__mro__ = mro
  textend(cls, obj)

  OBJ_ID = OBJ_ID + 1
  cls.__id = OBJ_ID

  setmetatable(cls, meta)

  return cls
end

object = {
  __name__ = "object",
  ___py___ = TAG,
  __id = 0,

  __index = function (self, key)
    return getattr(self, key)
  end,
  __newindex = function(self, key, value)
    return setattr(self, key, value)
  end,
  __call = function (self, ...)
    return metacall(self, "__call__", ...)
  end,
  __tostring = function (self, ...)
    return metacall(self, "__str__", ...)
  end,
  __unm = function (self, ...)
    return metacall(self, "__neg__", ...)
  end,
  __add = function (self, ...)
    return metacall(self, "__add__", ...)
  end,
  __sub = function (self, ...)
    return metacall(self, "__sub__", ...)
  end,
  __mul = function (self, ...)
    return metacall(self, "__mul__", ...)
  end,
  __div = function (self, ...)
    return metacall(self, "__div__", ...)
  end,
  __mod = function (self, ...)
    return metacall(self, "__mod__", ...)
  end,
  __pow = function (self, ...)
    return metacall(self, "__pow__", ...)
  end,
  __concat = function (self, other)
    return tostring(self)..tostring(other)
  end,
  __len = function (self, ...)
    return metacall(self, "__len__", ...)
  end,
  __eq = function (self, ...)
    return metacall(self, "__eq__", ...)
  end,
  __lt = function (self, ...)
    return metacall(self, "__lt__", ...)
  end,
  __le = function (self, ...)
    return metacall(self, "__le__", ...)
  end,

  __new__ = function(cls, ...)
    OBJ_ID = OBJ_ID + 1
    local instance = {__id = OBJ_ID}

    setmetatable(instance, cls)
    metacall(instance, "__init__", ...)

    return instance
  end,
  __getattribute__ = function(self, key)
    local value, mtable

    value = rawget(self, key)
    if value ~= nil then return value end

    mtable = getmetatable(self)
    value = rawget(mtable, key)
    if value ~= nil then
      if rawtype(value) == "function" then
        return function (...)
          return value(self, ...)
        end
      else
        return value
      end
    end
  end,
  __setattr__ = function(self, key, value)
    rawset(self, key, value)
  end,
  __delattr__ = function(self, key)
    rawset(obj, key, nil)
  end,
  __hasattr__ = function(self, key)
    return getattr(self, key) ~= nil
  end,
  __str__ = function(self, ...)
    return metacall(self, "__repr__", ...)
  end,
  __lua__ = function (self)
    return self
  end,
  __eq__ = function(self, other)
    return raw_compare(self, other, function ()
      return self == other
    end)
  end,
  __lt__ = function(self, other)
    return raw_compare(self, other, function ()
      return self < other
    end)
  end,
  __le__ = function(self, ...)
    return metacall(self, "__eq__", ...) and metacall(self, "__lt__", ...)
  end,

  __repr__ = function(self)
    return "<object '"..type(self).__name__.."' at "..self.__id..">"
  end,
  __call__ = function(self)
    error("TypeError: '"..type(self).__name__.."' object is not callable")
  end,
  __init__ = function(self)
  end
}

type = textend(tcopy(object), {
  __name__ = "type",

  __call__ = function(cls, ...)
    return cls:__new__(...)
  end,
  __repr__ = function(cls)
    return "<class '"..cls.__name__.."'>"
  end,
  mro = function(cls)
    return cls.__mro__
  end
})

ptype = textend(tcopy(type), {
  __call__ = function (cls, ...)
    local args = {...}
    if #args == 1 then
      if not is_pyobj(args[1]) then
        error("This is not vaild python obj."..tostring(args[1]))
      end

      if args[1] == type then
        return type
      end

      return getmetatable(args[1])
    elseif #args == 3 then

    else
      error("Unexcepted arguments.")
    end
  end
})

type = define_class(ptype, type, object)
object = define_class(type, object)

function __build_class__(cls, name, ...)
  local cls = tcopy(cls)
  textend(cls, {
    __name__ = name,
  })

  return define_class(type, cls, object, ...)
end

BaseException = __build_class__({
  __repr__ = function (self)
    return "BaseException("..repr(self.args)..")"
  end
}, "BaseException")

Exception = __build_class__({

}, "Exception")

ListTupleMixin = {
  __init__ = function(self, value)
    if value == nil then
      value = {}
    end

    assert(self._check_iter_values_only(value))
    self.value = value
  end,

  _check_iter_values_only = function(self, value)
    if rawtype(value) == "table" then
      if #value == 0 then
        return true
      elseif value[#value] == nil then
      elseif value[1] == nil then
      elseif value[0] ~= nil then
      else
        return true
      end

      return false
    end

    return false
  end,
}

list = __build_class__(tsub(ListTupleMixin, {
  __getitem__ = function(self, key)
    local value
    key = to_luaobj(key) - 1
    value = self.value[key]

    if value == nil then
      error("KeyError")
    else
      return value
    end
  end,
  __repr__ = function(self)
    local insert = table.insert
    local buf = {}

    insert(buf, "[")
    for value in pairs(self.value) do
      insert(buf, repr(value))
      insert(buf, ", ")
    end

    if #buf > 1 then
      table.remove(buf)
    end

    insert(buf, "]")
    return table.concat(buf)
  end
}), "list")

function do_math_calc(self, other, func)
  local cls = getmetatable(self)
  other = to_pyobj(other)

  value = func(self.value, other.value)
  if isinstance(self, float) or isinstance(other, float) then
    cls = float
  elseif is_float(value) then -- is_float_value
    cls = float
  end

  return cls(value)
end

NumberMixIn = {
  __init__ = function(self, value)
    self.value = value
  end,
  __repr__ = function(self)
    return tostring(self.value)
  end,
  __lua__ = function(self)
    return self.value
  end,
  __repr__ = function(self)
    return tostring(self.value)
  end,
  __lua__ = function(self)
    return self.value
  end,
  __add__ = function(self, other)
    return do_math_calc(self, other, function(a, b)
      return a + b
    end)
  end,
  __sub__ = function(self, other)
    return do_math_calc(self, other, function(a, b)
      return a - b
    end)
  end,
  __mul__ = function(self, other)
    return do_math_calc(self, other, function(a, b)
      return a * b
    end)
  end,
  __div__ = function(self, other)
    return do_math_calc(self, other, function(a, b)
      return a / b
    end)
  end,
  __mod__ = function(self, other)
    return do_math_calc(self, other, function(a, b)
      return a % b
    end)
  end,
  __pow__ = function(self, other)
    return do_math_calc(self, other, function(a, b)
      return a ^ b
    end)
  end,
  __neg__ = function(self)
    return getmetatable(self)(-self.value)
  end
}

int = __build_class__(tsub(NumberMixIn, {
  __init__ = function(self, value)
    self.value = math.floor(value)
  end
}), "int")

float = __build_class__(NumberMixIn, "float")