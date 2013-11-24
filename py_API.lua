local _M = getfenv(1);
if pyscripter then -- [LINE 1]
  exit(__import__('pc').main()); -- [LINE 1]
end;
 -- [LINE 3]
if not getmetatable(_M) or _G == _M then -- [LINE 6]
  _M = setmetatable({['_G'] = _G}, {['__index'] = _G}); -- [LINE 12]
  setfenv(1, _M); -- [LINE 13]
end;
lua = {}; -- [LINE 16]
lua.len = (function(obj) return #obj; end); -- [LINE 17]
lua.concat = (function(...) return table.concat({...}); end); -- [LINE 18]
lua.write = write or io.write; -- [LINE 19]
local key, value;
for key, value in pairs(_G) do -- [LINE 20]
  lua[key] = value; -- [LINE 21]
end;
local PY_OBJ_TAG = '#'; -- [LINE 23]
local LUA_OBJ_TAG = '@'; -- [LINE 24]
local TAG = '[PY]'; -- [LINE 26]
local ObjLastID = 0; -- [LINE 27]
local inited = False; -- [LINE 28]
local builtins = 'builtins'; -- [LINE 30]
local ObjID = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 33]
local ObjValue = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 34]
local ObjPCEX = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 35]
local Obj_FromID = setmetatable({}, {['__mode'] = 'v'}); -- [LINE 36]
local BuiltinTypes = setmetatable({}, {['__mode'] = 'k'}); -- [LINE 37]
local InitalBuiltinTypes = {}; -- [LINE 41]
local builtin_methods = {'__new__', '__init__', '__del__', '__repr__', '__str__', '__bytes__', '__format__', '__lt__', '__le__', '__eq__', '__ne__', '__gt__', '__ge__', '__hash__', '__bool__', '__getattr__', '__getattribute__', '__setattr__', '__delattr__', '__dir__', '__get__', '__set__', '__delete__', '__slots__', '__call__', '__len__', '__getitem__', '__setitem__', '__delitem__', '__iter__', '__reversed__', '__contains__', '__add__', '__sub__', '__mul__', '__truediv__', '__floordiv__', '__mod__', '__divmod__', '__pow__', '__lshift__', '__rshift__', '__and__', '__xor__', '__or__', '__radd__', '__rsub__', '__rmul__', '__rtruediv__', '__rfloordiv__', '__rmod__', '__rdivmod__', '__rpow__', '__rlshift__', '__rrshift__', '__rand__', '__rxor__', '__ror__', '__iadd__', '__isub__', '__imul__', '__itruediv__', '__ifloordiv__', '__imod__', '__ipow__', '__ilshift__', '__irshift__', '__iand__', '__ixor__', '__ior__', '__neg__', '__pos__', '__abs__', '__invert__', '__complex__', '__int__', '__float__', '__round__', '__index__', '__enter__', '__exit__', '__lua__'}; -- [LINE 44]
local builtin_methods_rev = {}; -- [LINE 45]
local k, v;
for k, v in pairs(builtin_methods) do -- [LINE 46]
  builtin_methods_rev[v] = k; -- [LINE 47]
end;
assert(builtin_methods[42] == '__rshift__'); -- [LINE 49]
assert(builtin_methods_rev['__pos__'] == 72); -- [LINE 50]
local error = nil; -- [LINE 51]
local function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 54]
    error('This is not number', 2); -- [LINE 55]
  end;
  return math.floor(num) ~= num; -- [LINE 57]
end;
local function is_pyobj(obj)
  return ObjID[obj] ~= nil; -- [LINE 60]
end;
local function PObj(obj)
  if is_pyobj(obj) then -- [LINE 63]
    return obj; -- [LINE 64]
  else
    return LuaObject(obj); -- [LINE 66]
  end;
end;
local function LObj(obj)
  if is_pyobj(obj) then -- [LINE 69]
    return _OP__Lua__(obj); -- [LINE 70]
  else
    return obj; -- [LINE 72]
  end;
end;
local function require_pyobj(...)
  local objs = {...};
  local idx, obj;
  for idx, obj in pairs(objs) do -- [LINE 75]
    if not is_pyobj(obj) then -- [LINE 76]
      lua.print(lua.type(obj), obj); -- [LINE 77]
      error('Require python object.'); -- [LINE 78]
    end;
  end;
  return true; -- [LINE 80]
end;
local function register_pyobj(obj)
  ObjLastID = (ObjLastID + 1); -- [LINE 84]
  local obj_id = ObjLastID; -- [LINE 85]
  ObjID[obj] = obj_id; -- [LINE 87]
  Obj_FromID[obj_id] = obj; -- [LINE 88]
  return obj; -- [LINE 89]
end;
function error(msg, level)
  if level == nil then -- [LINE 92]
    level = 1; -- [LINE 93]
  end;
  if is_pyobj(msg) then -- [LINE 95]
    msg = LObj(msg); -- [LINE 96]
  end;
  level = (level + 1); -- [LINE 98]
  lua.error(lua.concat(TAG, ' ', tostring(msg)), level); -- [LINE 99]
end;
local function require_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 102]
    if value == nil then -- [LINE 103]
      error('SystemError: Not Enough Item'); -- [LINE 104]
    end;
  end;
  return True; -- [LINE 106]
end;
local function nonrequire_args(...)
  local args = {...};
  local key, value;
  for key, value in pairs(args) do -- [LINE 109]
    if value ~= nil then -- [LINE 110]
      error('SystemError: Not Enough Item'); -- [LINE 111]
    end;
  end;
  return True; -- [LINE 113]
end;
function is_float(num)
  if lua.type(num) ~= 'number' then -- [LINE 116]
    error('This is not number', 2); -- [LINE 117]
  end;
  return math.floor(num) ~= num; -- [LINE 119]
end;
local function setup_base_class(cls)
  local pcex = {}; -- [LINE 122]
  local k, v;
  for k, v in pairs(cls) do -- [LINE 123]
    local idx = builtin_methods_rev[k]; -- [LINE 124]
    if idx ~= nil then -- [LINE 125]
      pcex[idx] = v; -- [LINE 126]
    end;
  end;
  ObjPCEX[cls] = pcex; -- [LINE 128]
  InitalBuiltinTypes[cls] = false; -- [LINE 129]
  register_pyobj(cls); -- [LINE 130]
  return cls; -- [LINE 132]
end;
local function setup_basic_class(cls)
  setup_base_class(cls); -- [LINE 135]
  setmetatable(cls, type); -- [LINE 136]
  return cls; -- [LINE 138]
end;
local function setup_hide_class(cls)
  InitalBuiltinTypes[cls] = nil; -- [LINE 141]
  return cls; -- [LINE 142]
end;
local function register_builtins_class(cls)
  local idx = 1; -- [LINE 145]
  local mro = {}; -- [LINE 146]
  mro[idx] = cls; -- [LINE 148]
  idx = (idx + 1); -- [LINE 149]
  local bases = rawget(cls, '__bases__'); -- [LINE 151]
  if bases ~= nil then -- [LINE 152]
    for i = #bases, 1, -1 do --; -- [LINE 153]
    if true then -- [LINE 154]
      local base = bases[i]; -- [LINE 155]
      if InitalBuiltinTypes[base] ~= nil then -- [LINE 156]
        mro[idx] = base; -- [LINE 157]
        idx = (idx + 1); -- [LINE 158]
      end;
    end;
    end; -- [LINE 159]
  end;
  if cls ~= object then -- [LINE 161]
    mro[idx] = object; -- [LINE 162]
    idx = (idx + 1); -- [LINE 163]
  end;
  rawset(cls, '__bases__', nil); -- [LINE 165]
  rawset(cls, '__name__', str(rawget(cls, '__name__'))); -- [LINE 166]
  rawset(cls, '__module__', str('builtins')); -- [LINE 167]
  rawset(cls, '__mro__', tuple(mro)); -- [LINE 168]
  InitalBuiltinTypes[cls] = true; -- [LINE 170]
  return cls; -- [LINE 171]
end;
local function Fail_OP(a, ax)
  error(lua.concat(LObj(repr(a)), ' are not support ', builtin_methods[ax])); -- [LINE 174]
end;
local function Fail_OP_Raw(a, raw_ax)
  error(lua.concat(LObj(repr(a)), ' are not support ', raw_ax)); -- [LINE 177]
end;
local function Fail_OP_Math_Raw(a, b, raw_ax)
  error(lua.concat('Not support ', LObj(repr(a)), ' ', raw_ax, ' ', LObj(repr(b)))); -- [LINE 180]
end;
local function Fail_OP_Math(a, b, ax, extra)
  if extra == nil then -- [LINE 183]
    extra = ''; -- [LINE 184]
  else
    extra = lua.concat(' ', extra); -- [LINE 186]
  end;
  error(lua.concat('Not support ', LObj(repr(a)), ' ', builtin_methods[ax], ' ', LObj(repr(b)), extra)); -- [LINE 188]
end;
local function Fail_OP_Math_Pow(a, b, ax, c)
  local extra = ''; -- [LINE 191]
  if c then -- [LINE 192]
    extra = lua.concat('% ', LObj(repr(c))); -- [LINE 193]
  end;
  Fail_OP_Math(a, b, ax, c); -- [LINE 195]
end;
local function OP_Call(ax)
  local function func(a, ...)
    local args = {...};
    assert(require_pyobj(a)); -- [LINE 199]
    local f = ObjPCEX[getmetatable(a)][ax]; -- [LINE 200]
    if f then -- [LINE 201]
      return f(a, ...); -- [LINE 202]
    end;
    Fail_OP(a, ax); -- [LINE 204]
  end;
  return func; -- [LINE 205]
end;
local function OP_Math2(ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 209]
    local am = ObjPCEX[getmetatable(a)]; -- [LINE 210]
    local bm = ObjPCEX[getmetatable(b)]; -- [LINE 211]
    local f = am[ax]; -- [LINE 213]
    if f then -- [LINE 214]
      local ret = f(a, b); -- [LINE 215]
      if ret ~= NotImplemented then -- [LINE 216]
        return ret; -- [LINE 216]
      end;
    end;
    f = bm[bx]; -- [LINE 218]
    if f then -- [LINE 219]
      ret = f(b, a); -- [LINE 220]
      if ret ~= NotImplemented then -- [LINE 221]
        return ret; -- [LINE 221]
      end;
    end;
    Fail_OP_Math(a, b, ax); -- [LINE 223]
  end;
  return func; -- [LINE 225]
end;
local function OP_Math3(cx, ax, bx)
  local function func(a, b)
    assert(require_pyobj(a, b)); -- [LINE 229]
    local am = ObjPCEX[getmetatable(a)]; -- [LINE 230]
    local bm = ObjPCEX[getmetatable(b)]; -- [LINE 231]
    local is_n = isinstance(a, int) == True or isinstance(b, float) == True; -- [LINE 232]
    if is_n then -- [LINE 234]
      local f = am[ax]; -- [LINE 235]
      if f then -- [LINE 236]
        local ret = f(a, b); -- [LINE 237]
        if ret ~= NotImplemented then -- [LINE 238]
          return ret; -- [LINE 238]
        end;
      end;
    end;
    f = am[cx]; -- [LINE 240]
    if f then -- [LINE 241]
      ret = f(a, b); -- [LINE 242]
      if ret ~= NotImplemented then -- [LINE 243]
        return ret; -- [LINE 243]
      end;
    end;
    if not is_n then -- [LINE 246]
      f = am[ax]; -- [LINE 247]
      if f then -- [LINE 248]
        ret = f(a, b); -- [LINE 249]
        if ret ~= NotImplemented then -- [LINE 250]
          return ret; -- [LINE 250]
        end;
      end;
    end;
    f = bm[bx]; -- [LINE 252]
    if f then -- [LINE 253]
      ret = f(b, a); -- [LINE 254]
      if ret ~= NotImplemented then -- [LINE 255]
        return ret; -- [LINE 255]
      end;
    end;
    Fail_OP_Math(a, b, cx); -- [LINE 257]
  end;
  return func; -- [LINE 259]
end;
local function OP_Math2_Pow(ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 263]
    assert(require_pyobj(c) or c == nil); -- [LINE 264]
    local am = ObjPCEX[getmetatable(a)]; -- [LINE 265]
    local bm = ObjPCEX[getmetatable(b)]; -- [LINE 266]
    local f = am[ax]; -- [LINE 268]
    if f then -- [LINE 269]
      local ret = f(a, b, c); -- [LINE 270]
      if ret ~= NotImplemented then -- [LINE 271]
        return ret; -- [LINE 271]
      end;
    end;
    if c ~= nil then -- [LINE 273]
      f = bm[bx]; -- [LINE 278]
      if f then -- [LINE 279]
        ret = f(b, a); -- [LINE 280]
        if ret ~= NotImplemented then -- [LINE 281]
          return ret; -- [LINE 281]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 283]
  end;
  return func; -- [LINE 285]
end;
local function OP_Math3_Pow(cx, ax, bx)
  local function func(a, b, c)
    assert(require_pyobj(a, b)); -- [LINE 289]
    assert(require_pyobj(c) or c == nil); -- [LINE 290]
    local am = ObjPCEX[getmetatable(a)]; -- [LINE 291]
    local bm = ObjPCEX[getmetatable(b)]; -- [LINE 292]
    local f = am[cx]; -- [LINE 294]
    if f then -- [LINE 295]
      local ret = f(a, b, c); -- [LINE 296]
      if ret ~= NotImplemented then -- [LINE 297]
        return ret; -- [LINE 297]
      end;
    end;
    f = am[ax]; -- [LINE 299]
    if f then -- [LINE 300]
      ret = f(a, b, c); -- [LINE 301]
      if ret ~= NotImplemented then -- [LINE 302]
        return ret; -- [LINE 302]
      end;
    end;
    if c ~= nil then -- [LINE 304]
      f = bm[bx]; -- [LINE 305]
      if f then -- [LINE 306]
        ret = f(b, a); -- [LINE 307]
        if ret ~= NotImplemented then -- [LINE 308]
          return ret; -- [LINE 308]
        end;
      end;
    end;
    Fail_OP_Math_Pow(a, b, ax, c); -- [LINE 310]
  end;
  return func; -- [LINE 312]
end;
function _OP__Is__(a, b)
  require_pyobj(a, b); -- [LINE 316]
  return ObjID[a] == ObjID[b]; -- [LINE 317]
end;
function _OP__IsNot__(a, b)
  return not _OP__Is__(a, b); -- [LINE 320]
end;
local function _(name)
  return builtin_methods_rev[name]; -- [LINE 322]
end;
 -- [LINE 323]
_OP__New__ = OP_Call(_('__new__')); -- [LINE 325]
_OP__Init__ = OP_Call(_('__init__')); -- [LINE 326]
_OP__Del__ = OP_Call(_('__del__')); -- [LINE 327]
_OP__Repr__ = OP_Call(_('__repr__')); -- [LINE 328]
_OP__Str__ = OP_Call(_('__str__')); -- [LINE 329]
_OP__Bytes__ = OP_Call(_('__bytes__')); -- [LINE 330]
_OP__Format__ = OP_Call(_('__format__')); -- [LINE 331]
_OP__Lt__ = OP_Call(_('__lt__')); -- [LINE 332]
_OP__Le__ = OP_Call(_('__le__')); -- [LINE 333]
_OP__Eq__ = OP_Call(_('__eq__')); -- [LINE 334]
_OP__Ne__ = OP_Call(_('__ne__')); -- [LINE 335]
_OP__Gt__ = OP_Call(_('__gt__')); -- [LINE 336]
_OP__Ge__ = OP_Call(_('__ge__')); -- [LINE 337]
_OP__Hash__ = OP_Call(_('__hash__')); -- [LINE 338]
_OP__Bool__ = OP_Call(_('__bool__')); -- [LINE 339]
_OP__Getattr__ = OP_Call(_('__getattr__')); -- [LINE 340]
_OP__Getattribute__ = OP_Call(_('__getattribute__')); -- [LINE 341]
_OP__Setattr__ = OP_Call(_('__setattr__')); -- [LINE 342]
_OP__Delattr__ = OP_Call(_('__delattr__')); -- [LINE 343]
_OP__Dir__ = OP_Call(_('__dir__')); -- [LINE 344]
_OP__Get__ = OP_Call(_('__get__')); -- [LINE 345]
_OP__Set__ = OP_Call(_('__set__')); -- [LINE 346]
_OP__Delete__ = OP_Call(_('__delete__')); -- [LINE 347]
_OP__Slots__ = OP_Call(_('__slots__')); -- [LINE 348]
_OP__Call__ = OP_Call(_('__call__')); -- [LINE 349]
_OP__Len__ = OP_Call(_('__len__')); -- [LINE 350]
_OP__Getitem__ = OP_Call(_('__getitem__')); -- [LINE 351]
_OP__Setitem__ = OP_Call(_('__setitem__')); -- [LINE 352]
_OP__Delitem__ = OP_Call(_('__delitem__')); -- [LINE 353]
_OP__Iter__ = OP_Call(_('__iter__')); -- [LINE 354]
_OP__Reversed__ = OP_Call(_('__reversed__')); -- [LINE 355]
_OP__Contains__ = OP_Call(_('__contains__')); -- [LINE 356]
_OP__Add__ = OP_Math2(_('__add__'), _('__radd__')); -- [LINE 359]
_OP__Sub__ = OP_Math2(_('__sub__'), _('__rsub__')); -- [LINE 360]
_OP__Mul__ = OP_Math2(_('__mul__'), _('__rmul__')); -- [LINE 361]
_OP__Truediv__ = OP_Math2(_('__truediv__'), _('__rtruediv__')); -- [LINE 362]
_OP__Floordiv__ = OP_Math2(_('__floordiv__'), _('__rfloordiv__')); -- [LINE 363]
_OP__Mod__ = OP_Math2(_('__mod__'), _('__rmod__')); -- [LINE 364]
_OP__Divmod__ = OP_Math2(_('__divmod__'), _('__rdivmod__')); -- [LINE 365]
_OP__Pow__ = OP_Math2_Pow(_('__pow__'), _('__rpow__')); -- [LINE 366]
_OP__Lshift__ = OP_Math2(_('__lshift__'), _('__rlshift__')); -- [LINE 367]
_OP__Rshift__ = OP_Math2(_('__rshift__'), _('__rrshift__')); -- [LINE 368]
_OP__And__ = OP_Math2(_('__and__'), _('__rand__')); -- [LINE 369]
_OP__Xor__ = OP_Math2(_('__xor__'), _('__rxor__')); -- [LINE 370]
_OP__Or__ = OP_Math2(_('__or__'), _('__ror__')); -- [LINE 371]
_OP__Iadd__ = OP_Math3(_('__iadd__'), _('__add__'), _('__radd__')); -- [LINE 374]
_OP__Isub__ = OP_Math3(_('__isub__'), _('__sub__'), _('__rsub__')); -- [LINE 375]
_OP__Imul__ = OP_Math3(_('__imul__'), _('__mul__'), _('__rmul__')); -- [LINE 376]
_OP__Itruediv__ = OP_Math3(_('__itruediv__'), _('__truediv__'), _('__rtruediv__')); -- [LINE 377]
_OP__Ifloordiv__ = OP_Math3(_('__ifloordiv__'), _('__floordiv__'), _('__rfloordiv__')); -- [LINE 378]
_OP__Imod__ = OP_Math3(_('__imod__'), _('__mod__'), _('__rmod__')); -- [LINE 379]
_OP__Ipow__ = OP_Math3_Pow(_('__ipow__'), _('__pow__'), _('__rpow__')); -- [LINE 380]
_OP__Ilshift__ = OP_Math3(_('__ilshift__'), _('__lshift__'), _('__rlshift__')); -- [LINE 381]
_OP__Irshift__ = OP_Math3(_('__irshift__'), _('__rshift__'), _('__rrshift__')); -- [LINE 382]
_OP__Iand__ = OP_Math3(_('__iand__'), _('__and__'), _('__rand__')); -- [LINE 383]
_OP__Ixor__ = OP_Math3(_('__ixor__'), _('__xor__'), _('__rxor__')); -- [LINE 384]
_OP__Ior__ = OP_Math3(_('__ior__'), _('__or__'), _('__ror__')); -- [LINE 385]
_OP__Neg__ = OP_Call(_('__neg__')); -- [LINE 388]
_OP__Pos__ = OP_Call(_('__pos__')); -- [LINE 389]
_OP__Abs__ = OP_Call(_('__abs__')); -- [LINE 390]
_OP__Invert__ = OP_Call(_('__invert__')); -- [LINE 391]
_OP__Complex__ = OP_Call(_('__complex__')); -- [LINE 392]
_OP__Int__ = OP_Call(_('__int__')); -- [LINE 393]
_OP__Float__ = OP_Call(_('__float__')); -- [LINE 394]
_OP__Round__ = OP_Call(_('__round__')); -- [LINE 395]
_OP__Index__ = OP_Call(_('__index__')); -- [LINE 396]
_OP__Enter__ = OP_Call(_('__enter__')); -- [LINE 397]
_OP__Exit__ = OP_Call(_('__exit__')); -- [LINE 398]
_OP__Lua__ = OP_Call(_('__lua__')); -- [LINE 401]
function repr(obj)
  if is_pyobj(obj) then -- [LINE 405]
    return _OP__Repr__(obj); -- [LINE 406]
  else
    return lua.concat(LUA_OBJ_TAG, '(', tostring(obj), ')'); -- [LINE 408]
  end;
end;
function print(...)
  local args = {...};
  local arr = {}; -- [LINE 411]
  local idx = 1; -- [LINE 412]
  local _, arg;
  for _, arg in pairs(args) do -- [LINE 414]
    if is_pyobj(arg) then -- [LINE 415]
      arg = str(arg); -- [LINE 416]
    else
      arg = repr(arg); -- [LINE 418]
    end;
    arg = LObj(arg); -- [LINE 420]
    arr[idx] = arg; -- [LINE 422]
    idx = (idx + 1); -- [LINE 423]
  end;
  local data = table.concat(arr, ' '); -- [LINE 425]
  data = lua.concat(data, '\n'); -- [LINE 426]
  lua.write(data); -- [LINE 427]
end;
function isinstance(obj, targets)
  require_pyobj(obj); -- [LINE 430]
  local cls = type(obj); -- [LINE 432]
  local mro = cls.mro(); -- [LINE 433]
  assert(type(mro) == list); -- [LINE 434]
  local _, supercls;
  for _, supercls in pairs(ObjValue[mro]) do -- [LINE 436]
    require_pyobj(supercls); -- [LINE 437]
    if supercls == targets then -- [LINE 438]
      return True; -- [LINE 439]
    end;
  end;
  return False; -- [LINE 441]
end;
function issubclass(cls, targets)
  require_pyobj(obj); -- [LINE 444]
  if type(cls) ~= type then -- [LINE 446]
    error('issubclass() arg 1 must be a class'); -- [LINE 447]
  end;
  local mro = cls.mro(); -- [LINE 449]
  assert(type(mro) == list); -- [LINE 450]
  local _, supercls;
  for _, supercls in pairs(ObjValue[mro]) do -- [LINE 452]
    require_pyobj(supercls); -- [LINE 453]
    if supercls == targets then -- [LINE 454]
      return True; -- [LINE 455]
    end;
  end;
  return False; -- [LINE 457]
end;
function id(obj)
  if is_pyobj(obj) then -- [LINE 460]
    return int(ObjID[obj]); -- [LINE 461]
  end;
  Fail_OP_Raw(obj, '__id!'); -- [LINE 463]
end;
function len(obj)
  return _OP__Len__(obj); -- [LINE 466]
end;
 -- [LINE 468]
_ = nil; -- [LINE 469]
object = (function(_M)--(object)
  local scope = setmetatable({}, {__index=_M})
;scope.__name__ = 'object';
  function doload()
    function __init__(self)
    end;
    setfenv(__init__, _M);
    function __call(self, ...)
      local args = {...};
      return _OP__Call__(self, ...); -- [LINE 479]
    end;
    setfenv(__call, _M);
    function __index(self, key)
      return _OP__Getattribute__(self, key); -- [LINE 482]
    end;
    setfenv(__index, _M);
    function __newindex(self, key, value)
      return _OP__Setattr__(self, key, value); -- [LINE 485]
    end;
    setfenv(__newindex, _M);
    function __tostring(self)
      return lua.concat(PY_OBJ_TAG, '(', LObj(repr(self)), ')'); -- [LINE 488]
    end;
    setfenv(__tostring, _M);
    function __new__(cls, ...)
      local args = {...};
      local instance = {}; -- [LINE 491]
      instance = register_pyobj(instance); -- [LINE 492]
      lua.setmetatable(instance, cls); -- [LINE 493]
      _OP__Init__(instance, ...); -- [LINE 494]
      return instance; -- [LINE 496]
    end;
    setfenv(__new__, _M);
    function __getattribute__(self, k)
      local v = rawget(self, k); -- [LINE 499]
      if v ~= nil then -- [LINE 500]
        return v; -- [LINE 501]
      end;
      local mt = getmetatable(self); -- [LINE 503]
      v = rawget(mt, k); -- [LINE 504]
      if v ~= nil then -- [LINE 505]
        if lua.type(v) == 'function' then -- [LINE 506]
          return (function(...) return v(self, unpack({...})); end); -- [LINE 507]
        else
          return v; -- [LINE 509]
        end;
      end;
      error(lua.concat("Not found '", k, "' attribute.")); -- [LINE 511]
    end;
    setfenv(__getattribute__, _M);
    function __setattr__(self, key, value)
      if BuiltinTypes[type(self)] and inited then -- [LINE 514]
        error("TypeError: can't set attributes of built-in/extension type 'object'"); -- [LINE 515]
      end;
      rawset(self, key, value); -- [LINE 518]
    end;
    setfenv(__setattr__, _M);
    function __str__(self)
      return _OP__Repr__(self); -- [LINE 521]
    end;
    setfenv(__str__, _M);
    function __repr__(self)
      local mtable = getmetatable(self); -- [LINE 524]
      return str(lua.concat('<object ', LObj(mtable.__name__), ' at ', LObj(id(self)), '>')); -- [LINE 525]
    end;
    setfenv(__repr__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
object = setup_base_class(object);
type = (function(_M)--(type: object)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {object};
  scope.__name__ = 'type';
  function doload()
    function __call__(cls, ...)
      local args = {...};
      local instance = cls.__new__(cls, ...); -- [LINE 531]
      register_pyobj(instance); -- [LINE 532]
      return instance; -- [LINE 534]
    end;
    setfenv(__call__, _M);
    function __repr__(cls)
      return str(lua.concat("<class '", LObj(cls.__name__), "'>")); -- [LINE 537]
    end;
    setfenv(__repr__, _M);
    function mro(cls)
      return list(ObjValue[cls.__mro__]); -- [LINE 540]
    end;
    setfenv(mro, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
type = setup_base_class(type);
local ptype = (function(_M)--(ptype: type)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({type}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {type};
  scope.__name__ = 'ptype';
  function doload()
    function __call__(cls, ...)
      local args = {...};
      if lua.len(args) == 1 then -- [LINE 545]
        require_pyobj(args[1]); -- [LINE 546]
        return getmetatable(args[1]); -- [LINE 547]
      elseif lua.len(args) == 3 then -- [LINE 548]
      else
        error('Unexcepted arguments.'); -- [LINE 551]
      end;
    end;
    setfenv(__call__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
ptype = setup_base_class(ptype);
setmetatable(object, type); -- [LINE 553]
setmetatable(type, ptype); -- [LINE 554]
setmetatable(ptype, ptype); -- [LINE 555]
local BaseException = (function(_M)--(BaseException: object)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {object};
  scope.__name__ = 'BaseException';
  function doload()
    args = nil; -- [LINE 561]
    function __new__(cls, ...)
      local args = {...};
      local param = tuple(args); -- [LINE 564]
      local instance = object.__new__(cls); -- [LINE 565]
      rawset(instance, 'args', param); -- [LINE 566]
      _OP__Init__(instance, param); -- [LINE 567]
      return instance; -- [LINE 568]
    end;
    setfenv(__new__, _M);
    function __str__(self)
      local length = LObj(len(self.args)); -- [LINE 571]
      if length == 0 then -- [LINE 572]
        return str(''); -- [LINE 573]
      elseif length == 1 then -- [LINE 574]
        return str(_OP__Getitem__(self.args, int(0))); -- [LINE 575]
      end;
    end;
    setfenv(__str__, _M);
    function __repr__(self)
      local excname = LObj(type(self).__name__); -- [LINE 578]
      return lua.concat(excname, repr(self.args)); -- [LINE 579]
    end;
    setfenv(__repr__, _M);
    function __lua__(self)
      local excname = LObj(type(self).__name__); -- [LINE 582]
      local value = str(self); -- [LINE 583]
      if LObj(len(value)) > 0 then -- [LINE 585]
        return lua.concat(excname, ': ', LObj(value)); -- [LINE 586]
      else
        return lua.concat(excname); -- [LINE 588]
      end;
    end;
    setfenv(__lua__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
BaseException = setup_basic_class(BaseException);
local Exception = (function(_M)--(Exception: BaseException)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({BaseException}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {BaseException};
  scope.__name__ = 'Exception';
  function doload()
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
Exception = setup_basic_class(Exception);
local UnstableException = (function(_M)--(UnstableException: Exception, BaseException)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({BaseException, Exception}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {Exception, BaseException};
  scope.__name__ = 'UnstableException';
  function doload()
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
UnstableException = setup_basic_class(UnstableException);
local BuiltinConstType = (function(_M)--(BuiltinConstType: object)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {object};
  scope.__name__ = 'BuiltinConstType';
  function doload()
    function __new__(cls, ...)
      local args = {...};
      if not inited then -- [LINE 601]
        local instance = object.__new__(cls, ...); -- [LINE 602]
        _OP__Init__(instance, ...); -- [LINE 603]
        return instance; -- [LINE 604]
      end;
      return cls._get_singleton(); -- [LINE 606]
    end;
    setfenv(__new__, _M);
    function _get_singleton(cls)
      error('Not defined.'); -- [LINE 609]
    end;
    setfenv(_get_singleton, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
BuiltinConstType = setup_basic_class(BuiltinConstType);
local NotImplementedType = (function(_M)--(NotImplementedType: BuiltinConstType)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({BuiltinConstType}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {BuiltinConstType};
  scope.__name__ = 'NotImplementedType';
  function doload()
    function _get_singleton(cls)
      return NotImplemented; -- [LINE 614]
    end;
    setfenv(_get_singleton, _M);
    function __repr__(self)
      return str('NotImplemented'); -- [LINE 617]
    end;
    setfenv(__repr__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
NotImplementedType = setup_basic_class(NotImplementedType);
local EllipsisType = (function(_M)--(EllipsisType: BuiltinConstType)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({BuiltinConstType}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {BuiltinConstType};
  scope.__name__ = 'EllipsisType';
  function doload()
    function _get_singleton(self)
      return Ellipsis; -- [LINE 622]
    end;
    setfenv(_get_singleton, _M);
    function __repr__(self)
      return str('Ellipsis'); -- [LINE 625]
    end;
    setfenv(__repr__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
EllipsisType = setup_basic_class(EllipsisType);
local NoneType = (function(_M)--(NoneType: BuiltinConstType)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({BuiltinConstType}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {BuiltinConstType};
  scope.__name__ = 'NoneType';
  function doload()
    function _get_singleton(cls)
      return None; -- [LINE 630]
    end;
    setfenv(_get_singleton, _M);
    function __repr__(self)
      return str('None'); -- [LINE 633]
    end;
    setfenv(__repr__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
NoneType = setup_basic_class(NoneType);
local LuaObject = (function(_M)--(LuaObject: object)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({object}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {object};
  scope.__name__ = 'LuaObject';
  function doload()
    LuaObject = true; -- [LINE 639]
    function __init__(self, obj)
      local mtable = getmetatable(obj); -- [LINE 643]
      if mtable and rawget(mtable, 'LuaObject') then -- [LINE 644]
        obj = LObj(obj); -- [LINE 645]
      end;
      ObjValue[self] = obj; -- [LINE 647]
    end;
    setfenv(__init__, _M);
    function __str__(self)
      return str(_OP__Repr__(self)); -- [LINE 650]
    end;
    setfenv(__str__, _M);
    function __repr__(self)
      return str(tostring(ObjValue[self])); -- [LINE 653]
    end;
    setfenv(__repr__, _M);
    function __lua__(self)
      return ObjValue[self]; -- [LINE 656]
    end;
    setfenv(__lua__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
LuaObject = setup_basic_class(LuaObject);
LuaObject = setup_hide_class(LuaObject);
local LuaValueOnlySequance = (function(_M)--(LuaValueOnlySequance: LuaObject)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {LuaObject};
  scope.__name__ = 'LuaValueOnlySequance';
  function doload()
    function __init__(self, value)
      if is_pyobj(value) then -- [LINE 662]
        self.check_type(value); -- [LINE 663]
      end;
      ObjValue[self] = value; -- [LINE 665]
    end;
    setfenv(__init__, _M);
    function check_type(self, value)
      if type(value) == 'table' then -- [LINE 668]
      elseif value[lua.len(value)] == nil then -- [LINE 669]
      elseif value[1] == nil then -- [LINE 670]
      elseif value[0] ~= nil then -- [LINE 671]
      else
        return true; -- [LINE 673]
      end;
      return false; -- [LINE 675]
    end;
    setfenv(check_type, _M);
    function make_repr(self, s, e)
      local ret = {}; -- [LINE 678]
      local idx = 1; -- [LINE 679]
      local sep = ''; -- [LINE 681]
      ret[idx] = s; -- [LINE 682]
      idx = (idx + 1); -- [LINE 682]
      local k, v;
      for k, v in pairs(ObjValue[self]) do -- [LINE 683]
        ret[idx] = sep; -- [LINE 684]
        idx = (idx + 1); -- [LINE 684]
        ret[idx] = LObj(repr(v)); -- [LINE 685]
        idx = (idx + 1); -- [LINE 685]
        sep = ', '; -- [LINE 686]
      end;
      ret[idx] = e; -- [LINE 688]
      idx = (idx + 1); -- [LINE 688]
      return table.concat(ret); -- [LINE 690]
    end;
    setfenv(make_repr, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
LuaValueOnlySequance = setup_basic_class(LuaValueOnlySequance);
LuaValueOnlySequance = setup_hide_class(LuaValueOnlySequance);
list = (function(_M)--(list: LuaValueOnlySequance)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({LuaValueOnlySequance}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {LuaValueOnlySequance};
  scope.__name__ = 'list';
  function doload()
    function __repr__(self)
      return self.make_repr('[', ']'); -- [LINE 696]
    end;
    setfenv(__repr__, _M);
    function __setattr__(self, key, value)
      error('Not allowed'); -- [LINE 699]
    end;
    setfenv(__setattr__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
list = setup_basic_class(list);
tuple = (function(_M)--(tuple: LuaValueOnlySequance)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({LuaValueOnlySequance}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {LuaValueOnlySequance};
  scope.__name__ = 'tuple';
  function doload()
    function __repr__(self)
      return self.make_repr('(', ')'); -- [LINE 705]
    end;
    setfenv(__repr__, _M);
    function __setattr__(self, key, value)
      error('Not allowed'); -- [LINE 708]
    end;
    setfenv(__setattr__, _M);
    function __len__(self)
      return int(lua.len(ObjValue[self])); -- [LINE 711]
    end;
    setfenv(__len__, _M);
    function __getitem__(self, x)
      assert(is_pyobj(x)); -- [LINE 714]
      if isinstance(x, int) then -- [LINE 715]
        return ObjValue[self][(LObj(x) + 1)]; -- [LINE 716]
      end;
      error('Not support unknown type.'); -- [LINE 718]
    end;
    setfenv(__getitem__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
tuple = setup_basic_class(tuple);
str = (function(_M)--(str: LuaObject)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {LuaObject};
  scope.__name__ = 'str';
  function doload()
    function __init__(self, value)
      if is_pyobj(value) then -- [LINE 724]
        value = _OP__Str__(value); -- [LINE 725]
        value = LObj(value); -- [LINE 726]
      end;
      ObjValue[self] = value; -- [LINE 728]
    end;
    setfenv(__init__, _M);
    function __str__(self)
      return self; -- [LINE 731]
    end;
    setfenv(__str__, _M);
    function __repr__(self)
      return str(lua.concat("'", ObjValue[self], "'")); -- [LINE 734]
    end;
    setfenv(__repr__, _M);
    function __len__(self)
      return int(lua.len(ObjValue[self])); -- [LINE 737]
    end;
    setfenv(__len__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
str = setup_basic_class(str);
bool = (function(_M)--(bool: LuaObject)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {LuaObject};
  scope.__name__ = 'bool';
  function doload()
    function __new__(cls, value)
      if not inited then -- [LINE 743]
        local instance = object.__new__(cls); -- [LINE 744]
        ObjValue[instance] = value; -- [LINE 745]
        return instance; -- [LINE 746]
      end;
      if is_pyobj(value) then -- [LINE 748]
        value = _OP__Bool__(value); -- [LINE 749]
      else
        value = value and true or false; -- [LINE 752]
      end;
      if value == true then -- [LINE 754]
        return True; -- [LINE 755]
      elseif value == false then -- [LINE 756]
        return False; -- [LINE 757]
      elseif is_pyobj(value) and type(value) == bool then -- [LINE 758]
        return value; -- [LINE 759]
      end;
      error('__Bool__ are returned unknown value.'); -- [LINE 761]
    end;
    setfenv(__new__, _M);
    function __repr__(self)
      local value = ObjValue[self]; -- [LINE 764]
      if value == true then -- [LINE 765]
        return str('True'); -- [LINE 766]
      elseif value == false then -- [LINE 767]
        return str('False'); -- [LINE 768]
      end;
    end;
    setfenv(__repr__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
bool = setup_basic_class(bool);
int = (function(_M)--(int: LuaObject)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {LuaObject};
  scope.__name__ = 'int';
  function doload()
    function __add__(self, other)
      return int((ObjValue[self] + ObjValue[other])); -- [LINE 776]
    end;
    setfenv(__add__, _M);
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
int = setup_basic_class(int);
dict = (function(_M)--(dict: LuaObject)
  local scope = setmetatable({}, {__index=_M})
;(function(o,c,k,v)
    for k,c in pairs({LuaObject}) do
      for k,v in pairs(c) do o[k]=v end
    end
  end)(scope);
  scope.__bases__ = {LuaObject};
  scope.__name__ = 'dict';
  function doload()
  end;
  setfenv(doload, scope);
  doload();
  return scope;
end)(_M);
dict = setup_basic_class(dict);
local function inital()
  local cls, _;
  for cls, _ in pairs(InitalBuiltinTypes) do -- [LINE 786]
    register_builtins_class(cls); -- [LINE 787]
    BuiltinTypes[cls] = true; -- [LINE 788]
  end;
  InitalBuiltinTypes = nil; -- [LINE 789]
  _M['NotImplemented'] = NotImplementedType(); -- [LINE 791]
  _M['Ellipsis'] = EllipsisType(); -- [LINE 792]
  _M['None'] = NoneType(); -- [LINE 793]
  _M['True'] = bool(true); -- [LINE 794]
  _M['False'] = bool(false); -- [LINE 795]
  return true; -- [LINE 797]
end;
inited = inital(); -- [LINE 799]
print(str('Hello world!')); -- [LINE 803]
