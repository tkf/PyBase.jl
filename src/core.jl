using PyCall

abstract type AbstractShim end
super(shim::AbstractShim) = shim.self
PyCall.docstring(shim::AbstractShim) = PyCall.docstring(super(shim))
Base.showable(mime::MIME, shim::AbstractShim) = showable(mime, super(shim))
Base.show(io::IO, mime::MIME, shim::AbstractShim) = show(io, mime, super(shim))
Base.show(io::IO, shim::AbstractShim) = show(io, super(shim))

_unwrap(x::Any) = x

__getattr__(self::Any, name::AbstractString) = __getattr__(self, Symbol(name))
__setattr__(self::Any, name::AbstractString, value) =
    __setattr__(self, Symbol(name), value)
__delattr__(self::Any, name::AbstractString) = __delattr__(self, Symbol(name))

@shimmed begin
    __getattr__(self::Any, name::Symbol) = __getattr__(self, Val(name))
    __setattr__(self::Any, name::Symbol, value::Any) =
        __setattr__(self, Val(name), value)
    __delattr__(self::Any, name::Symbol) = __delattr__(self, Val(name))
end

function __getattr__(self::Any, @nospecialize(_::Val{name})) where name
    try
        return getproperty(self, name)
    catch ex
        ex isa UndefVarError || rethrow()
    end
    pyraise(pybuiltin("AttributeError")(String(name)))
end

function __setattr__(self::Any, @nospecialize(_::Val{name}), value::Any
                     ) where name
    try
        setproperty!(self, name, value)
    catch
        pyraise(pybuiltin("AttributeError")(String(name)))
    end
    return nothing
end

function __delattr__(::Any, @nospecialize(_::Val{name})) where name
    pyraise(pybuiltin("AttributeError")(String(name)))
    return nothing
end

function __dir__(m::Module; kwargs...)
    members = String[]
    for sym in names(m; all=true, kwargs...)
        str = string(sym)
        startswith(str, "#") && continue
        startswith(str, "@") && continue
        push!(members, rstrip(str, '!'))
    end
    return members
end

@shimmed __dir__(m; all=true) = collect(String.(propertynames(m, all)))

convert_itemkey(shim::AbstractShim, key) = convert_itemkey(super(shim), key)

@shimmed begin
    __getitem__(self, key) =
        getindex(self, convert_itemkey(self, key)...)
    __setitem__(self, key, value) =
        setindex!(self, value, convert_itemkey(self, key)...)
    __delitem__(self, key) =
        delete!(self, convert_itemkey(self, key)...)
end
