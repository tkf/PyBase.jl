"""
    PyBase.__getattr__(self, ::Val{name::Symbol})
    PyBase.__getattr__(self, name::Symbol)

Python's attribute getter interface
[`__getattr__`](https://docs.python.org/3/reference/datamodel.html#object.__getattr__).

Roughly speaking, the default implementation is:

```julia
__getattr__(self, name::Symbol) = __getattr__(self, Val(name))
__getattr__(self, ::Val{name}) = getproperty(self, name)
```

To add a specific Python property to `self`, overload
`__getattr__(::MyType, ::Val{name})`.  Use `__getattr__(::MyType, ::Symbol)`
to fully control the attribute access in Python.

At the lowest level (which is invoked directly by Python), `PyBase`
defines `__getattr__(self, name::String) = __getattr__(self, Symbol(name))`
this can be used for advanced control when using predefined wrappers.
However, `__getattr__(::Shim{MyType}, ::String)` has to be overloaded
instead of `__getattr__(::MyType, ::String)`.
"""
PyBase.__getattr__

"""
    PyBase.__setattr__(self, ::Val{name::Symbol}, value)
    PyBase.__setattr__(self, name::Symbol, value)

Python's attribute setter interface
[`__setattr__`](https://docs.python.org/3/reference/datamodel.html#object.__setattr__).
Default implementation invokes `setproperty!`.
See [`PyBase.__getattr__`](@ref).
"""
PyBase.__setattr__

"""
    PyBase.delattr(self, ::Val{name::Symbol})
    PyBase.delattr(self, name::Symbol)

Python's attribute deletion interface
[`__delattr__`](https://docs.python.org/3/reference/datamodel.html#object.__delattr__).
Default implementation raises `AttributeError` in Python.
See [`PyBase.__getattr__`](@ref).
"""
PyBase.__delattr__

"""
Python's `__dir__`
"""
PyBase.__dir__

"""
    PyBase.convert_itemkey(self, key::Tuple)

Often [`__getitem__`](@ref), [`__setitem__`](@ref) and
[`__delitem__`](@ref) can be directly mapped to `getindex`,
`setindex!` and `delete!` respectively, provided that the
key/(multi-)index is mapped correctly.  This mapping is done by
`convert_itemkey`.  The default implementation does a lot of magics (=
run-time introspection) to convert Python/Numpy-like semantics to
Julia-like semantics.
"""
PyBase.convert_itemkey

"""
    __getitem__(self, key)

Python's
[`__getitem__`](https://docs.python.org/3/reference/datamodel.html#object.__getitem__).
Default implementation is:

```julia
getindex(self, convert_itemkey(self, key)...)
```
"""
PyBase.__getitem__

"""
    __setitem__(self, key, value)

Python's
[`__setitem__`](https://docs.python.org/3/reference/datamodel.html#object.__setitem__).
Default implementation is:

```julia
setindex!(self, value, convert_itemkey(self, key)...)
```

Note that the order of `key` and `value` for `__setitem__` is the opposite of
`setindex!`.
"""
PyBase.__setitem__

"""
    __delitem__(self, key)

Python's
[`__delitem__`](https://docs.python.org/3/reference/datamodel.html#object.__delitem__).
Default implementation is:

```julia
delete!(self, convert_itemkey(self, key)...)
```
"""
PyBase.__delitem__
