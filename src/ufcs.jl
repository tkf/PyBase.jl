"""
Uniform Function Call Syntax [^UFCS] wrapper.

Usage:

```julia
PyCall.PyObject(self::MyModule.MyType) = PyBase.UFCS.wrap(self)
```

It then translates Python method call `self.NAME(*args, **kwargs)` to

```julia
MyModule.MyType.NAME(self, args...; kwargs...)  # or
MyModule.MyType.NAME!(self, args...; kwargs...)
```

in Julia where `NAME` is a placeholder (i.e., it can be a method named
`solve` or `plot`).  If both `NAME` and `NAME!` exist, `NAME!` is used
unless `False` is passed to the special keyword argument `inplace`, i.e.,

```python
# in Python:                               #    in Julia:
self.NAME(*args, **kwargs)                 # => NAME(self, args...; kwargs...)
                                           # or NAME!(self, args...; kwargs...)
self.NAME(*args, inplace=False, **kwargs)  # => NAME(self, args...; kwargs...)
self.NAME(*args, inplace=True, **kwargs)   # => NAME!(self, args...; kwargs...)
```

The modules in which method `NAME` is searched can be specified as a
keyword argument to `PyBase.UFCS.wrap`:

```julia
using MyBase, MyModule
PyCall.PyObject(self::MyType) = PyBase.UFCS.wrap(self,
                                                 modules = [MyBase, MyModule])
```

The first match in the list of modules is used.

Usual method overloading of

```julia
PyBase.getattr(self::MyModule.MyType, name::Symbol)  # and/or
PyBase.getattr(self::MyModule.MyType, ::Val{name})
```

can still control the behavior of Python's `__getattr__` *if* `name`
is not already handled by the above UFCS mechanism.

[^UFCS]: [Uniform Function Call Syntax --- Wikipedia](https://en.wikipedia.org/wiki/Uniform_Function_Call_Syntax)
"""
module UFCS

import PyCall
using ..PyBase
using ..JuliaAPI: JuliaObject, convert_pyindices

struct Shim{T} <: PyBase.AbstractShim
    self::T
    methods::Dict{Symbol, Any}
    modules::Vector{Module}
end
# If this is not fast enough, we can get the UUID of the modules, put
# them in the type parameter, and then generate the wrapper in a
# @generated or @pure function.

_process_method(location::Tuple{Symbol, Any}) = location

function _process_method(location::Function)
    n = nameof(location)
    if n == :anonymous
        throw(ArgumentError(
            "Use `(name::Symbol, f)` to specify an anonymous function"))
    end
    return (n, location)
end

process_methods(methods::Dict{Symbol, Any}) = methods

process_methods(methods::AbstractVector) =
    Dict{Symbol, Any}(_process_method.(methods))
# TODO: error on repeated keys

Shim(self::T;
     methods = [],
     modules::Vector{Module} = [parentmodule(T)]) where T =
    Shim(self,
         process_methods(methods),
         modules)

"""
    PyBase.UFCS.wrap(self; methods, modules) :: PyObject

"Uniform Function Call Syntax" wrapper.  See [`PyBase.UFCS`](@ref) for details.
"""
wrap(self; kwargs...) = JuliaObject(Shim(self; kwargs...))

struct MethodShim
    name::Symbol
    f
    shim::Shim
end

(f::MethodShim)(args...; kwargs...) = f.f(f.shim.self, args...; kwargs...)

function Base.show(io::IO, f::MethodShim)
    print(io, "[shim] ")
    show(io, f.f)
end

PyCall.docstring(f::MethodShim) = PyCall.docstring(f.f)

struct DualMethodShim
    name::Symbol
    inp
    oop
    shim::Shim
end

struct Unspecified end

function (f::DualMethodShim)(args...;
                             inplace::Union{Unspecified, Bool} = Unspecified(),
                             kwargs...)
    if inplace isa Unspecified
        if applicable(f.inp, f.shim.self, args...)
            # Default to inplace=true.
            return f.inp(f.shim.self, args...; kwargs...)
        elseif applicable(f.oop, f.shim.self, args...)
            return f.oop(f.shim.self, args...; kwargs...)
        else
            error("$(f.inp) and $(f.oop) do not support given arguments")
        end
    end
    if inplace
        f.inp(f.shim.self, args...; kwargs...)
    else
        f.oop(f.shim.self, args...; kwargs...)
    end
end

function Base.show(io::IO, f::DualMethodShim)
    print(io, "[shim] ")
    show(io, f.inp)
    print(io, " | ")
    show(io, f.oop)
end

function PyCall.docstring(f::DualMethodShim)
    oop_name = string(f.oop)
    inp_name = string(f.inp)
    return """
    A wrapper of $oop_name and $inp_name.

    If keyword argument `inplace=True` (default) is given, it
    calls $inp_name.  If `inplace=False` is given, it calls
    $oop_name.

    ---

    $(PyCall.docstring(f.oop))

    ---

    $(PyCall.docstring(f.inp))
    """
end

function lookup_function(modules, name)
    for m in modules
        if isdefined(m, name)
            return getproperty(m, name)
        end
    end
end

function PyBase.getattr(shim::Shim, name::Symbol)
    if haskey(shim.methods, name)
        return MethodShim(name, shim.methods[name], shim)
    end
    name! = Symbol(name, :!)
    inp_fun = lookup_function(shim.modules, name!)
    oop_fun = lookup_function(shim.modules, name)
    if inp_fun != nothing && oop_fun != nothing
        return DualMethodShim(name, inp_fun, oop_fun, shim)
    elseif inp_fun != nothing
        return MethodShim(name, inp_fun, shim)
    elseif oop_fun != nothing
        return MethodShim(name, oop_fun, shim)
    else
        return PyBase.getattr(shim.self, name)
    end
end

end  # module
