"""
    PyBase.getattr(self, ::Val{name::Symbol})
    PyBase.getattr(self, name::Symbol)

Python's attribute getter interface
[`__getattr__`](https://docs.python.org/3/reference/datamodel.html#object.__getattr__).

Roughly speaking, the default implementation is:

```julia
getattr(self, name::Symbol) = getattr(self, Val(name))
getattr(self, ::Val{name}) = getproperty(self, name)
```

To add a specific Python property to `self`, overload
`getattr(::MyType, ::Val{name})`.  Use `getattr(::MyType, ::Symbol)`
to fully control the attribute access in Python.

At the lowest level (which is invoked directly by Python), `PyBase`
defines `getattr(self, name::String) = getattr(self, Symbol(name))`
this can be used for advanced control when using predefined wrappers.
However, `getattr(::Shim{MyType}, ::String)` has to be overloaded
instead of `getattr(::MyType, ::String)`.
"""
PyBase.getattr

"""
    PyBase.setattr!(self, ::Val{name::Symbol}, value)
    PyBase.setattr!(self, name::Symbol, value)

Python's attribute setter interface
[`__setattr__`](https://docs.python.org/3/reference/datamodel.html#object.__setattr__).
Default implementation invokes `setproperty!`.
See [`PyBase.getattr`](@ref).
"""
PyBase.setattr!

"""
    PyBase.delattr(self, ::Val{name::Symbol})
    PyBase.delattr(self, name::Symbol)

Python's attribute deletion interface
[`__delattr__`](https://docs.python.org/3/reference/datamodel.html#object.__delattr__).
Default implementation raises `AttributeError` in Python.
See [`PyBase.getattr`](@ref).
"""
PyBase.delattr!

"""
Python's `__dir__`
"""
PyBase.dir

"""
    PyBase.convert_itemkey(self, key::Tuple)

Often [`getitem`](@ref), [`setitem!`](@ref) and [`delitem!`](@ref) can
be directly mapped to `getindex`, `setindex!` and `delete!`
respectively, provided that the key/(multi-)index is mapped correctly.
This mapping is done by `convert_itemkey`.  The default implementation
does a lot of magics (= run-time introspection) to convert
Python/Numpy-like semantics to Julia-like semantics.
"""
PyBase.convert_itemkey

"""
    getitem(self, key)

Python's
[`__getitem__`](https://docs.python.org/3/reference/datamodel.html#object.__getitem__).
Default implementation is:

```julia
getindex(self, convert_itemkey(self, key)...)
```
"""
PyBase.getitem

"""
    setitem!(self, key, value)

Python's
[`__setitem__`](https://docs.python.org/3/reference/datamodel.html#object.__setitem__).
Default implementation is:

```julia
setindex!(self, value, convert_itemkey(self, key)...)
```

Note that the order of `key` and `value` for `setitem!` is the opposite of
`setindex!`.
"""
PyBase.setitem!

"""
    delitem!(self, key)

Python's
[`__delitem__`](https://docs.python.org/3/reference/datamodel.html#object.__delitem__).
Default implementation is:

```julia
delete!(self, convert_itemkey(self, key)...)
```
"""
PyBase.delitem!
