var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "PyBase.jl",
    "title": "PyBase.jl",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#PyBase.jl-1",
    "page": "PyBase.jl",
    "title": "PyBase.jl",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#TL;DR-1",
    "page": "PyBase.jl",
    "title": "TL;DR",
    "category": "section",
    "text": "It\'s just one line (per type):using MyModule: MyType\nusing PyCall\nusing PyBase\n\nPyCall.PyObject(self::MyType) = PyBase.UFCS.wrap(self)\n# PyCall.PyObject(self::MyType) = PyBase.Plain.wrap(self)  # alternativeThen MyType can be usable from Python via from julia.MyModule import MyType."
},

{
    "location": "index.html#Overview-1",
    "page": "PyBase.jl",
    "title": "Overview",
    "category": "section",
    "text": "Suppose you have a Julia type and want to expose its API to the Python world:julia> mutable struct MyType\n           x::Number\n       end\n\njulia> add1!(self::MyType) = self.x += 1;\n\njulia> add2(self::MyType) = self.x + 2;\n\njulia> add3(self::MyType) = self.x + 3\n       add3!(self::MyType) = self.x += 3;Using PyBase, it is just a one line to wrap it into a Python interface:julia> using PyCall\n       using PyBase\n\njulia> PyCall.PyObject(self::MyType) = PyBase.UFCS.wrap(self);Now MyType is usable from Python.  Here, for a demonstration purpose, let\'s send it to Python namespace using PyCall\'s @py_str macro:julia> py\"\"\"\n       MyType = $MyType  # emulating \"from julia.MyModule import MyType\"\n       \"\"\"Python users can now use MyType as if it is a Python function.julia> py\"\"\"\n       obj = MyType(0)\n       assert obj.x == 0\n       \"\"\"Since MyType uses PyBase.UFCS.wrap, Julia functions taking MyType as the first argument can be called as if it was a Python method of MyType:julia> py\"\"\"\n       obj.add1()\n       assert obj.x == 1\n       \"\"\"\n\njulia> py\"\"\"\n       assert obj.add2() == 3\n       assert obj.x == 1\n       \"\"\"\n\njulia> py\"\"\"\n       assert obj.add3(inplace=False) == 4\n       assert obj.x == 1\n       \"\"\"\n\njulia> py\"\"\"\n       obj.add3()  # default to inplace=True\n       assert obj.x == 4\n       \"\"\"It may be useful to provide custom Python methods.  This can be done by overloading PyBase.__getattr__:julia> PyBase.__getattr__(self::MyType, ::Val{:explicit_method}) =\n           (arg) -> \"explicit method call with $arg\"\n\njulia> py\"\"\"\n       assert obj.explicit_method(123) == \"explicit method call with 123\"\n       \"\"\"Note that various Julia interfaces are automatically usable from Python.  For example, indexing just works by translating indices as the offsets from Base.firstindex (which keeps 0-origin in Python side):julia> Base.firstindex(obj::MyType) = 1;\n\njulia> Base.getindex(obj::MyType, i::Integer) = i;\n\njulia> py\"\"\"\n       assert obj[0] == 1\n       \"\"\""
},

{
    "location": "index.html#Pre-defined-wrapper-factories-1",
    "page": "PyBase.jl",
    "title": "Pre-defined wrapper factories",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#PyBase.UFCS",
    "page": "PyBase.jl",
    "title": "PyBase.UFCS",
    "category": "module",
    "text": "Uniform Function Call Syntax [UFCS] wrapper.\n\nUsage:\n\nPyCall.PyObject(self::MyModule.MyType) = PyBase.UFCS.wrap(self)\n\nIt then translates Python method call self.NAME(*args, **kwargs) to\n\nMyModule.MyType.NAME(self, args...; kwargs...)  # or\nMyModule.MyType.NAME!(self, args...; kwargs...)\n\nin Julia where NAME is a placeholder (i.e., it can be a method named solve or plot).  If both NAME and NAME! exist, NAME! is used unless False is passed to the special keyword argument inplace, i.e.,\n\n# in Python:                               #    in Julia:\nself.NAME(*args, **kwargs)                 # => NAME(self, args...; kwargs...)\n                                           # or NAME!(self, args...; kwargs...)\nself.NAME(*args, inplace=False, **kwargs)  # => NAME(self, args...; kwargs...)\nself.NAME(*args, inplace=True, **kwargs)   # => NAME!(self, args...; kwargs...)\n\nThe modules in which method NAME is searched can be specified as a keyword argument to PyBase.UFCS.wrap:\n\nusing MyBase, MyModule\nPyCall.PyObject(self::MyType) = PyBase.UFCS.wrap(self,\n                                                 modules = [MyBase, MyModule])\n\nThe first match in the list of modules is used.\n\nUsual method overloading of\n\nPyBase.__getattr__(self::MyModule.MyType, name::Symbol)  # and/or\nPyBase.__getattr__(self::MyModule.MyType, ::Val{name})\n\ncan still control the behavior of Python\'s __getattr__ if name is not already handled by the above UFCS mechanism.\n\n[UFCS]: Uniform Function Call Syntax –- Wikipedia\n\n\n\n\n\n"
},

{
    "location": "index.html#PyBase.UFCS.wrap",
    "page": "PyBase.jl",
    "title": "PyBase.UFCS.wrap",
    "category": "function",
    "text": "PyBase.UFCS.wrap(self; methods, modules) :: PyObject\n\n\"Uniform Function Call Syntax\" wrapper.  See PyBase.UFCS for details.\n\n\n\n\n\n"
},

{
    "location": "index.html#\"Uniform-Function-Call-Syntax\"-1",
    "page": "PyBase.jl",
    "title": "\"Uniform Function Call Syntax\"",
    "category": "section",
    "text": "PyBase.UFCS\nPyBase.UFCS.wrap"
},

{
    "location": "index.html#PyBase.Plain",
    "page": "PyBase.jl",
    "title": "PyBase.Plain",
    "category": "module",
    "text": "Plain wrapper.\n\nUsage:\n\nPyCall.PyObject(self::MyModule.MyType) = PyBase.Plain.wrap(self)\n\n\n\n\n\n"
},

{
    "location": "index.html#PyBase.Plain.wrap",
    "page": "PyBase.jl",
    "title": "PyBase.Plain.wrap",
    "category": "function",
    "text": "PyBase.Plain.wrap(self) :: PyObject\n\n\n\n\n\n"
},

{
    "location": "index.html#Plain-1",
    "page": "PyBase.jl",
    "title": "Plain",
    "category": "section",
    "text": "PyBase.Plain\nPyBase.Plain.wrap"
},

{
    "location": "index.html#PyBase.__getattr__",
    "page": "PyBase.jl",
    "title": "PyBase.__getattr__",
    "category": "function",
    "text": "PyBase.__getattr__(self, ::Val{name::Symbol})\nPyBase.__getattr__(self, name::Symbol)\n\nPython\'s attribute getter interface __getattr__.\n\nRoughly speaking, the default implementation is:\n\n__getattr__(self, name::Symbol) = __getattr__(self, Val(name))\n__getattr__(self, ::Val{name}) = getproperty(self, name)\n\nTo add a specific Python property to self, overload __getattr__(::MyType, ::Val{name}).  Use __getattr__(::MyType, ::Symbol) to fully control the attribute access in Python.\n\nAt the lowest level (which is invoked directly by Python), PyBase defines __getattr__(self, name::String) = __getattr__(self, Symbol(name)) this can be used for advanced control when using predefined wrappers. However, __getattr__(::Shim{MyType}, ::String) has to be overloaded instead of __getattr__(::MyType, ::String).\n\n\n\n\n\n"
},

{
    "location": "index.html#PyBase.__setattr__",
    "page": "PyBase.jl",
    "title": "PyBase.__setattr__",
    "category": "function",
    "text": "PyBase.__setattr__(self, ::Val{name::Symbol}, value)\nPyBase.__setattr__(self, name::Symbol, value)\n\nPython\'s attribute setter interface __setattr__. Default implementation invokes setproperty!. See PyBase.__getattr__.\n\n\n\n\n\n"
},

{
    "location": "index.html#PyBase.__delattr__",
    "page": "PyBase.jl",
    "title": "PyBase.__delattr__",
    "category": "function",
    "text": "PyBase.delattr(self, ::Val{name::Symbol})\nPyBase.delattr(self, name::Symbol)\n\nPython\'s attribute deletion interface __delattr__. Default implementation raises AttributeError in Python. See PyBase.__getattr__.\n\n\n\n\n\n"
},

{
    "location": "index.html#PyBase.__dir__",
    "page": "PyBase.jl",
    "title": "PyBase.__dir__",
    "category": "function",
    "text": "Python\'s __dir__\n\n\n\n\n\n"
},

{
    "location": "index.html#PyBase.convert_itemkey",
    "page": "PyBase.jl",
    "title": "PyBase.convert_itemkey",
    "category": "function",
    "text": "PyBase.convert_itemkey(self, key::Tuple)\n\nOften __getitem__, __setitem__ and __delitem__ can be directly mapped to getindex, setindex! and delete! respectively, provided that the key/(multi-)index is mapped correctly.  This mapping is done by convert_itemkey.  The default implementation does a lot of magics (= run-time introspection) to convert Python/Numpy-like semantics to Julia-like semantics.\n\n\n\n\n\n"
},

{
    "location": "index.html#PyBase.__getitem__",
    "page": "PyBase.jl",
    "title": "PyBase.__getitem__",
    "category": "function",
    "text": "__getitem__(self, key)\n\nPython\'s __getitem__. Default implementation is:\n\ngetindex(self, convert_itemkey(self, key)...)\n\n\n\n\n\n"
},

{
    "location": "index.html#PyBase.__setitem__",
    "page": "PyBase.jl",
    "title": "PyBase.__setitem__",
    "category": "function",
    "text": "__setitem__(self, key, value)\n\nPython\'s __setitem__. Default implementation is:\n\nsetindex!(self, value, convert_itemkey(self, key)...)\n\nNote that the order of key and value for __setitem__ is the opposite of setindex!.\n\n\n\n\n\n"
},

{
    "location": "index.html#PyBase.__delitem__",
    "page": "PyBase.jl",
    "title": "PyBase.__delitem__",
    "category": "function",
    "text": "__delitem__(self, key)\n\nPython\'s __delitem__. Default implementation is:\n\ndelete!(self, convert_itemkey(self, key)...)\n\n\n\n\n\n"
},

{
    "location": "index.html#PyBase.__add__",
    "page": "PyBase.jl",
    "title": "PyBase.__add__",
    "category": "function",
    "text": "__add__(self, other)\n\nPython\'s __add__. Default implementation is roughly: broadcast(+, self, other).\n\n\n\n\n\n"
},

{
    "location": "index.html#PyBase.__radd__",
    "page": "PyBase.jl",
    "title": "PyBase.__radd__",
    "category": "function",
    "text": "__radd__(self, other)\n\nPython\'s __radd__. Default implementation: PyBase.__add__(other, self).\n\n\n\n\n\n"
},

{
    "location": "index.html#PyBase.__iadd__",
    "page": "PyBase.jl",
    "title": "PyBase.__iadd__",
    "category": "function",
    "text": "__iadd__(self, other)\n\nPython\'s __iadd__. If self is mutated, PyBase.mutated must be returned. Default implementation:\n\nfunction __iadd__(self, other)\n    broadcast!(+, self, self, other)\n    return PyBase.mutated\nend\n\n\n\n\n\n"
},

{
    "location": "index.html#Python-interface-methods-1",
    "page": "PyBase.jl",
    "title": "Python interface methods",
    "category": "section",
    "text": "PyBase provides interface for defining special methods for Python data model. Note that these methods do not follow Julia\'s convention that mutating functions have to end with ! to avoid extra complication of naming transformation.PyBase.__getattr__\nPyBase.__setattr__\nPyBase.__delattr__\nPyBase.__dir__\nPyBase.convert_itemkey\nPyBase.__getitem__\nPyBase.__setitem__\nPyBase.__delitem__\nPyBase.__add__\nPyBase.__radd__\nPyBase.__iadd__"
},

{
    "location": "index.html#List-of-supported-methods-1",
    "page": "PyBase.jl",
    "title": "List of supported methods",
    "category": "section",
    "text": "import Markdown\nimport PyBase\nMarkdown.MD(PyBase.SupportedMethods())"
},

]}
