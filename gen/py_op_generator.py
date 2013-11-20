attrsA = [
    # MUST NOT CHANGE ORDER!

    # START BASIC
    '__new__',
    '__init__',
    '__del__',
    '__repr__',
    '__str__',
    '__bytes__',
    '__format__',
    '__lt__',
    '__le__',
    '__eq__',
    '__ne__',
    '__gt__',
    '__ge__',
    '__hash__',
    '__bool__',
    '__getattr__',
    '__getattribute__',
    '__setattr__',
    '__delattr__',
    '__dir__',
    '__get__',
    '__set__',
    '__delete__',
    '__slots__',
    '__call__',
    '__len__',
    '__getitem__',
    '__setitem__',
    '__delitem__',
    '__iter__',
    '__reversed__',
    '__contains__',
]

at =[
    '__add__',
    '__sub__',
    '__mul__',
    '__truediv__',
    '__floordiv__',
    '__mod__',
    '__divmod__',
    '__pow__',
    '__lshift__',
    '__rshift__',
    '__and__',
    '__xor__',
    '__or__',
]

bt = [
    '__radd__',
    '__rsub__',
    '__rmul__',
    '__rtruediv__',
    '__rfloordiv__',
    '__rmod__',
    '__rdivmod__',
    '__rpow__',
    '__rlshift__',
    '__rrshift__',
    '__rand__',
    '__rxor__',
    '__ror__',
]

it = [
    '__iadd__',
    '__isub__',
    '__imul__',
    '__itruediv__',
    '__ifloordiv__',
    '__imod__',
    None,
    '__ipow__',
    '__ilshift__',
    '__irshift__',
    '__iand__',
    '__ixor__',
    '__ior__',
]

attrsB = [
    '__neg__',
    '__pos__',
    '__abs__',
    '__invert__',
    '__complex__',
    '__int__',
    '__float__',
    '__round__',
    '__index__',
    '__enter__',
    '__exit__',
    # END BASIC

    # NEXT METHOD ARE HERE
]

print("## Basic Call (Part A)")
for attr in attrsA:
    print("""
_OP__{0}__ = OP_Call(_M({1!r}))
""".strip().format(attr.title()[+2:-2], attr))
print()

print("## Math Operation (A * B)")
for a, b in zip(at, bt):
    print("""
_OP__{0}__ = OP_Math2(_M({1!r}), _M({2!r}))
""".strip().format(a.title()[+2:-2], a, b))
print()

print("## Math Operation (A *= B)")
for a, b, c in zip(at, bt, it):
    if c is None:
        continue

    print("""
_OP__{0}__ = OP_Math3(_M({3!r}), _M({1!r}), _M({2!r}))
""".strip().format(c.title()[+2:-2], a, b, c))
print()

print("## Basic Call (Part B)")
for attr in attrsB:
    print("""
_OP__{0}__ = OP_Call(_M({1!r}))
""".strip().format(attr.title()[+2:-2], attr))
print()