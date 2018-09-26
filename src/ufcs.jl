"""
Uniform Function Call Syntax [^UFCS] wrapper.

Usage:

```julia
PyCall.PyObject(self::MyModule.MyType) = PyBase.UFCS.wrap(self)
```

It then translates Python method call `self.NAME(args..., **kwargs)` to

```julia
MyModule.MyType.NAME(self, args...; kwargs...)  # or
MyModule.MyType.NAME!(self, args...; kwargs...)
```

in Julia where `NAME` is a placeholder (i.e., it can be a method named
`solve` or `plot`).  If both `NAME` and `NAME!` exist, `NAME` is used
unless `True` is passed to the keyword argument `inplace`, i.e.,

```python
# in Python:                               #    in Julia:
self.NAME(*args, **kwargs)                 # => NAME(self, *args, **kwargs)
self.NAME(*args, inplace=False, **kwargs)  # => NAME(self, *args, **kwargs)
self.NAME(*args, inplace=True, **kwargs)   # => NAME!(self, *args, **kwargs)
```

The modules in which method `NAME` is searched can be specified as the
second argument to `PyBase.UFCS.wrap`:

```julia
using MyBase, MyModule
PyCall.PyObject(self::MyType) = PyBase.UFCS.wrap(self, [MyBase, MyModule])
```

The first match in the list of modules is used.

Usual method overloading of

```julia
PyBase.getattr(self::MyModule.MyType, name::Symbol)  # and/or
PyBase.getattr(self::MyModule.MyType, ::Val{name})
```

can still control the behavior of Python's `__getattr__` **if** `name`
is not handled by the above UFCS mechanism.

[^UFCS]: [Uniform Function Call Syntax --- Wikipedia](https://en.wikipedia.org/wiki/Uniform_Function_Call_Syntax)
"""
module UFCS

using ..PyBase
using ..JuliaAPI: JuliaObject, convert_pyindices

struct Shim{T} <: PyBase.AbstractShim
    self::T
    modules::Vector{Module}
end
# If this is not fast enough, we can get the UUID of the modules, put
# them in the type parameter, and then generate the wrapper in a
# @generated or @pure function.

"""
    PyBase.UFCS.wrap(self, [modules]) :: PyObject

"Uniform Function Call Syntax" wrapper.  See [`PyBase.UFCS`](@ref) for details.
"""
wrap(x::T, modules::Vector{Module} = [parentmodule(T)]) where T =
    JuliaObject(Shim(x, modules))

function lookup_function(modules, name)
    for m in modules
        if isdefined(m, name)
            return getproperty(m, name)
        end
    end
end

function PyBase.getattr(shim::Shim, name::Symbol)
    name! = Symbol(name, :!)
    inp_fun = lookup_function(shim.modules, name!)
    oop_fun = lookup_function(shim.modules, name)
    if inp_fun != nothing && oop_fun != nothing
        # inplace=false by default (as in, e.g., pandas)
        return (args...; inplace=false, kwargs...) ->
            if inplace
                inp_fun(shim.self, args...; kwargs...)
            else
                oop_fun(shim.self, args...; kwargs...)
            end
    elseif inp_fun != nothing
        return (args...; kwargs...) -> inp_fun(shim.self, args...; kwargs...)
    elseif oop_fun != nothing
        return (args...; kwargs...) -> oop_fun(shim.self, args...; kwargs...)
    else
        return PyBase.getattr(shim.self, name)
    end
end

PyBase.convert_itemkey(shim::Shim, key) =
    convert_pyindices(shim.self, key)

end  # module
