import sys

from urllib.request import urlopen
from html.parser import HTMLParser

class LinkHRefCollector(HTMLParser):
    def reset(self):
        super().reset()
        self.links = []

    def handle_starttag(self, tag, attr):
        if tag.lower() == "a":
            attr = dict(attr)
            self.links.append(attr)

def collect_object_attr():
    collector = LinkHRefCollector()
    with urlopen("http://docs.python.org/3.3/reference/datamodel.html") as fp:
        data = fp.read().decode('utf-8', 'replace')

    result = []

    collector.feed(data)
    for link in collector.links:
        href = link.get("href")
        cls = link.get("class", "").split()
        if href.startswith("#object.") and "headerlink" in cls:
            result.append(href[len("#"):])

    return result

object_attr = """
__new__
__init__
__del__
__repr__
__str__
__bytes__
__format__
__lt__
__le__
__eq__
__ne__
__gt__
__ge__
__hash__
__bool__
__getattr__
__getattribute__
__setattr__
__delattr__
__dir__
__get__
__set__
__delete__
__slots__
__call__
__len__
__getitem__
__setitem__
__delitem__
__iter__
__reversed__
__contains__
__add__
__sub__
__mul__
__truediv__
__floordiv__
__mod__
__divmod__
__pow__
__lshift__
__rshift__
__and__
__xor__
__or__
__radd__
__rsub__
__rmul__
__rtruediv__
__rfloordiv__
__rmod__
__rdivmod__
__rpow__
__rlshift__
__rrshift__
__rand__
__rxor__
__ror__
__iadd__
__isub__
__imul__
__itruediv__
__ifloordiv__
__imod__
__ipow__
__ilshift__
__irshift__
__iand__
__ixor__
__ior__
__neg__
__pos__
__abs__
__invert__
__complex__
__int__
__float__
__round__
__index__
__enter__
__exit__
""".split()

def main():
    for line in object_attr:
        print(line)

    return
    for line in collect_object_attr():
        assert line.startswith("object.")
        print(line[len("object."):])

if __name__ == '__main__':
    main()
