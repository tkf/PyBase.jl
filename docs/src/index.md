# PyBase.jl

## Overview

Suppose you have a Julia type and expose its API to the Python world:

```jldoctest ufcs-example
julia> mutable struct MyType
           x::Number
       end

julia> add1!(self::MyType) = self.x += 1;

julia> add2(self::MyType) = self.x + 2;

julia> add3(self::MyType) = self.x + 3
       add3!(self::MyType) = self.x += 3;
```

Using `PyBase`, it is just a one line to wrap it into a Python
interface:

```jldoctest ufcs-example
julia> using PyCall
       using PyBase

julia> PyCall.PyObject(self::MyType) = PyBase.UFCS.wrap(self);
```

Then Python users can use `MyType` as a Python object constructor by
importing it `from julia.MyModule import MyType`.  Here, for a
demonstration purpose, let's send it to Python namespace using
PyCall's `@py_str` macro:

```jldoctest ufcs-example
julia> py"""
       MyType = $MyType  # emulating "from julia.MyModule import MyType"
       """
```

Python users can now use `MyType` as if it is a Python function.

```jldoctest ufcs-example
julia> py"""
       obj = MyType(0)
       assert obj.x == 0
       """
```

Since `MyType` uses [`PyBase.UFCS.wrap`](@ref), Julia functions taking
`MyType` as the first argument can be called as if it was a Python
method of `MyType`:

```jldoctest ufcs-example
julia> py"""
       obj.add1()
       assert obj.x == 1
       """

julia> py"""
       assert obj.add2() == 3
       assert obj.x == 1
       """

julia> py"""
       assert obj.add3(inplace=False) == 4
       assert obj.x == 1
       """

julia> py"""
       obj.add3()  # default to inplace=True
       assert obj.x == 4
       """
```

It may be useful to provide custom Python methods.  This can be done
by overloading [`PyBase.__getattr__`](@ref):

```jldoctest ufcs-example
julia> PyBase.__getattr__(self::MyType, ::Val{:explicit_method}) =
           (arg) -> "explicit method call with $arg"

julia> py"""
       assert obj.explicit_method(123) == "explicit method call with 123"
       """
```

## Pre-defined wrapper factories

### "Uniform Function Call Syntax"

```@docs
PyBase.UFCS
PyBase.UFCS.wrap
```

### Plain

```@docs
PyBase.Plain
PyBase.Plain.wrap
```

## Python interface methods

`PyBase` provides interface for defining special methods for
[Python data model](https://docs.python.org/3/reference/datamodel.html).
Note that these methods do _not_ follow Julia's convention that
mutating functions have to end with `!` to avoid extra complication of
naming transformation.

```@docs
PyBase.__getattr__
PyBase.__setattr__
PyBase.__delattr__
PyBase.__dir__
PyBase.convert_itemkey
PyBase.__getitem__
PyBase.__setitem__
PyBase.__delitem__
PyBase.__add__
PyBase.__radd__
PyBase.__iadd__
```

### List of supported methods

```@eval
import Markdown
import PyBase
Markdown.MD(PyBase.SupportedMethods())
```
