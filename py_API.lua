lua = {}; for k, v in pairs(_G) do lua[k] = v end lua._G = nil

__debug__ = True
__doc__ = ""

local TAG = '[PY]'
local OBJ_ID = 0

local function tcopy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

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
  if lua.type(num) == "number" then
    return math.floor(num) ~= num
  end

  error("This is not number", 2)
end

function error(msg, level)
  if level == nil then
    level = 1
  end

  level = level + 1
  lua.error(TAG.." "..msg, level)
end

local function require_pyobj(obj)
  if not is_pyobj(obj) then
    error("SystemError: Python object are require for execute.")
  end

  return true
end

local function require_args(...)
  for key, value in pairs({...}) do
    if value == nil then
      error("SystemError: Not Enough Item")
    end
  end

  return true
end

local function nonrequire_args(...)
  for key, value in pairs({...}) do
    if value ~= nil then
      error("SystemError: Too Many Item")
    end
  end

  return true
end


function is_pyobj(obj)
  local mtable = getmetatable(obj)
  return mtable and rawget(mtable, "___py___") == TAG
end

function to_pyobj(obj)
  if is_pyobj(obj) then
    return obj
  else
    local objtype = lua.type(obj)
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

    error("Lua object type '"..objtype.."' are not supported.")
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
  require_pyobj(obj)
  require_args(targets)

  local cls = type(obj)
  for _, supercls in pairs(cls.mro()) do
    if supercls == targets then
      return true
    end
  end

  return false
end

function len(obj)
  require_pyobj(obj)
  return to_pyobj(metacall(obj, "__len__"))
end

function raise(obj)
  if isinstance(obj, BaseException) then
    cls = type(obj)
    error(cls.__name__..": "..str(obj))
  else
    error("UnknownError: "..tostring(obj))
  end
end

function repr(obj)
  return to_pyobj(obj).__repr__()
end

function print(...)
  local write = lua.io.write

  local sep = " "
  for _, arg in pairs({...}) do
    write(to_luaobj(str(arg)))
    write(sep)
  end

  write("\n")
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

function metacall(obj, fname, ...)
  require_args(obj, fname)
  require_pyobj(obj)
  local value, mtable, status, result

  mtable = getmetatable(obj)
  value = rawget(mtable, fname)
  status, result = pcall(value, obj, ...)
  if not status then error(result, 2) else return result end
end

function rawmetacall(mtable, obj, fname, ...)
  require_args(mtable, obj, fname)
  require_pyobj(obj)
  local value, status, result

  value = rawget(mtable, fname)
  status, result = pcall(value, obj, ...)
  if not status then error(result, 2) else return result end
end

function getattr(obj, key, default)
  require_args(obj, key)
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

function setattr(obj, key, value, ...)
  require_args(obj, key, value)
  nonrequire_args(...)
  metacall(obj, "__setattr__", key, value)
end

function hasattr(obj, key, ...)
  require_args(obj, key)
  nonrequire_args(...)
  return metacall(obj, "__hasattr__", key)
end

function delattr(obj, key, ...)
  require_args(obj, key)
  nonrequire_args(...)
  return metacall(obj, "__delattr__", key)
end

local function raw_compare(a, b, func)
  require_args(a, b, func)
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
  require_args(meta, obj, ...)
  local cls, mro
  cls = {}
  mro = {}

  assert(obj.__name__)

  args = {...}
  textend(cls, object)
  table.insert(mro, object)

  for key, value in pairs(args) do
    textend(cls, value)
    table.insert(mro, value)
    for value in pairs(value.mro()) do
      -- FIX HERE (remove dup)
      table.insert(mro, value)
    end
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

  __index = function (self, key)
    require_args(key)
    return getattr(self, key)
  end,
  __newindex = function(self, key, value)
    require_args(key, value)
    return setattr(self, key, value)
  end,
  __call = function (self, ...)
    return metacall(self, "__call__", ...)
  end,
  __tostring = function (self)
    return metacall(self, "__str__")
  end,
  __unm = function (self)
    return metacall(self, "__neg__")
  end,
  __add = function (self, other)
    return metacall(self, "__add__", other)
  end,
  __sub = function (self, other)
    return metacall(self, "__sub__", other)
  end,
  __mul = function (self, other)
    return metacall(self, "__mul__", other)
  end,
  __div = function (self, other)
    return metacall(self, "__div__", other)
  end,
  __mod = function (self, other)
    return metacall(self, "__mod__", other)
  end,
  __pow = function (self)
    return metacall(self, "__pow__", other)
  end,
  __concat = function (self, other)
    return tostring(self)..tostring(other)
  end,
  __len = function (self)
    return metacall(self, "__len__")
  end,
  __eq = function (self, other)
    return metacall(self, "__eq__", other)
  end,
  __lt = function (self, other)
    return metacall(self, "__lt__", other)
  end,
  __le = function (self, other)
    return metacall(self, "__le__", other)
  end,

  __new__ = function(cls, ...)
    OBJ_ID = OBJ_ID + 1
    local instance = {__id = OBJ_ID}

    setmetatable(instance, cls)
    metacall(instance, "__init__", ...)

    return instance
  end,
  __getattribute__ = function(self, key, ...)
    require_args(key)
    nonrequire_args(...)
    local value, mtable

    value = rawget(self, key)
    if value ~= nil then return value end

    mtable = getmetatable(self)
    value = rawget(mtable, key)
    if value ~= nil then
      if lua.type(value) == "function" then
        return function (...)
          return value(self, ...)
        end
      else
        return value
      end
    end
  end,
  __setattr__ = function(self, key, value, ...)
    require_args(key, value)
    nonrequire_args(...)
    rawset(self, key, value)
  end,
  __delattr__ = function(self, key, ...)
    require_args(key)
    nonrequire_args(...)
    rawset(obj, key, nil)
  end,
  __hasattr__ = function(self, key, ...)
    nonrequire_args(...)
    return getattr(self, key) ~= nil
  end,
  __str__ = function(self, ...)
    nonrequire_args(...)
    return metacall(self, "__repr__", ...)
  end,
  __lua__ = function (self)
    return self
  end,
  __eq__ = function(self, other, ...)
    require_args(other)
    nonrequire_args(...)
    return raw_compare(self, other, function ()
      return self == other
    end)
  end,
  __lt__ = function(self, other, ...)
    require_args(other)
    nonrequire_args(...)
    return raw_compare(self, other, function ()
      return self < other
    end)
  end,
  __le__ = function(self, other, ...)
    require_args(other)
    nonrequire_args(...)
    return metacall(self, "__eq__", other) and metacall(self, "__lt__", other)
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

      return getmetatable(args[1])
    elseif #args == 3 then

    else
      error("Unexcepted arguments.")
    end
  end
})

type = define_class(ptype, type)
object = define_class(type, object)

function __build_class__(cls, name, ...)
  local cls = tcopy(cls)
  textend(cls, {
    __name__ = name,
  })

  return define_class(type, cls, object, ...)
end

BaseException = __build_class__({
  __init__ = function (self, ...)
    self.args = tuple({...})
  end,
  __repr__ = function (self)
    return type(self).self.."(*"..repr(self.args)..")"
  end,
  __str__ = function (self)
    if isinstance(self.args, tuple) then
      if len(self.args) ~= int(1) then
        return repr(self.args)
      else
        return self.args.__getitem__(0)
      end
    else
      return repr(self.args)
    end
  end
}, "BaseException")

Exception = __build_class__({

}, "Exception", BaseException)

ListTupleMixin = {
  __init__ = function(self, value)
    if value == nil then
      value = {}
    end

    assert(self._check_iter_values_only(value))
    self.value = value
  end,

  _check_iter_values_only = function(self, value)
    if lua.type(value) == "table" then
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

    key = to_pyobj(key)
    if not isinstance(key, int) then
      error("FAIL")
    end

    key = key.value - 1
    value = self.value[key]

    if value == nil then
      error("KeyError")
    else
      return value
    end
  end,
  __setitem__ = function(self, key)
    local value
    key = to_luaobj(key) + 1
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

tuple = __build_class__(tsub(ListTupleMixin, {
  __getitem__ = function(self, key)
    local value

    key = to_pyobj(key)
    if not isinstance(key, int) then
      error("FAIL")
    end

    key = key.value + 1
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

    insert(buf, "(")
    for value in pairs(self.value) do
      insert(buf, repr(value))
      insert(buf, ", ")
    end

    if #buf > 1 then
      table.remove(buf)
    end

    insert(buf, ")")
    return table.concat(buf)
  end,
  __len__ = function(self)
    return #self.value
  end
}), "tuple")

local function do_math_calc(self, other, func)
  local cls = type(self)
  local value

  other = to_pyobj(other)
  value = func(self.value, other.value)
  if isinstance(self, float) or isinstance(other, float) then
    cls = float
  elseif is_float(value) then -- is_float_value
    cls = float
  end

  return cls(value)
end

local function do_math_compare_calc(self, other, func)
  local cls = type(self)
  local value

  other = to_pyobj(other)
  return func(self.value, other.value)
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
  __lt__ = function(self, other)
    return do_math_compare_calc(self, other, function(a, b)
      return a < b
    end)
  end,
  __le__ = function(self, other)
    return do_math_compare_calc(self, other, function(a, b)
      return a <= b
    end)
  end,
  __eq__ = function(self, other)
    return do_math_compare_calc(self, other, function(a, b)
      return a == b
    end)
  end,
  __neg__ = function(self)
    return getmetatable(self)(-self.value)
  end
}

local int_dict = {}
int = __build_class__(tsub(NumberMixIn, {
  __init__ = function(self, value)
    self.value = math.floor(value)
  end,
  __new__ = function (cls, num) -- support base are later
    local value

    if int_dict[num] then
      return int_dict[num]
    elseif -16 <= num and num <= 256 then
      value = object.__new__(cls, num)
      int_dict[num] = value
      return value
    end
  end,
}), "int")

bool = __build_class__({
  __init__ = function(self, value)
    if value == true or value == false then
    elseif type(value).__len__ then
      value = to_luaobj(len(value)) ~= 0
    else
      value = not (not value)
    end

    self.value = value
  end,
  __repr__ = function(self)
    if self.value == true then
      return "True"
    elseif self.value == false then
      return "False"
    end
  end
}, "bool")

local NoneType = __build_class__({
  __init__ = function(self)
    if _G.None then
      error("None can't init multiple time.")
    end
  end,
  __repr__ = function(self)
    return "None"
  end
}, "NoneType")

float = __build_class__(NumberMixIn, "float")

str = __build_class__({
  __init__ = function(self, value)
    if is_pyobj(value) then
      value = value.__str__()
    elseif value == nil then
      value = "nil"
    else
      value = tostring(value)
    end

    self.value = value
  end,
  __str__ = function(self)
    return self.value
  end,
  __repr__ = function(self)
    return "/'"..self.value.."'/"
  end,
  __len__ = function(self)
    return #self.value
  end,
  __lua__ = function(self)
    return self.value
  end
}, "str")

True = bool(true)
False = bool(false)
None = NoneType()

function parse_call(func, ...)
  local tArgs = {...}
  if isinstance(tArgs[#tArgs]) then

  end

  table.remove(0)
end

function _OP__and__(a, b)
  return bool(a) == True and bool(b) == True
end

function _OP__or__(a, b)
  return bool(a) == True or bool(b) == True
end

function _OP__not__(a)
  -- # later: Fix the metacall
  return a.__not__()
end

function _OP__ASSIGN_ITEM__(a, k, v)
  return a.__setitem__(k, v)
end

function _OP__add__(a, b)
  return to_pyobj(a) + to_pyobj(b)
end

function _OP__sub__(a, b)
  return to_pyobj(a) - to_pyobj(b)
end

function _OP__mul__(a, b)
  return to_pyobj(a) * to_pyobj(b)
end

function _OP__div__(a, b)
  return to_pyobj(a) / to_pyobj(b)
end

function _OP__in__(a, b)
  return bool(metacall(a, "__contains__", b)) == True
end

function _OP__notin__(a, b)
  return a.__contains__(b)
end

function _OP__UNPACK__(v, limit)

end




print(True)
print(None)
print(isinstance(Exception(), BaseException))
raise(Exception())