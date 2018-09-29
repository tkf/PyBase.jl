using PyCall

abstract type AbstractShim end
super(shim::AbstractShim) = shim.self
PyCall.docstring(shim::AbstractShim) = PyCall.docstring(super(shim))
Base.showable(mime::MIME, shim::AbstractShim) = showable(mime, super(shim))
Base.show(io::IO, mime::MIME, shim::AbstractShim) = show(io, mime, super(shim))
Base.show(io::IO, shim::AbstractShim) = show(io, super(shim))

_unwrap(x::Any) = x

getattr(self::Any, name::AbstractString) = getattr(self, Symbol(name))
setattr!(self::Any, name::AbstractString, value) =
    setattr!(self, Symbol(name), value)
delattr!(self::Any, name::AbstractString) = delattr!(self, Symbol(name))

@shimmed begin
    getattr(self::Any, name::Symbol) = getattr(self, Val(name))
    setattr!(self::Any, name::Symbol, value::Any) =
        setattr!(self, Val(name), value)
    delattr!(self::Any, name::Symbol) = delattr!(self, Val(name))
end

function getattr(self::Any, @nospecialize(_::Val{name})) where name
    try
        return getproperty(self, name)
    catch ex
        ex isa UndefVarError || rethrow()
    end
    pyraise(pybuiltin("AttributeError")(String(name)))
end

function setattr!(self::Any, @nospecialize(_::Val{name}), value::Any) where name
    try
        setproperty!(self, name, value)
    catch
        pyraise(pybuiltin("AttributeError")(String(name)))
    end
    return nothing
end

function delattr!(::Any, @nospecialize(_::Val{name})) where name
    pyraise(pybuiltin("AttributeError")(String(name)))
    return nothing
end

dir(m::Module; kwargs...) = String.(names(m; all=true, kwargs...))
@shimmed dir(m; all=true) = String.(propertynames(m, all))

convert_itemkey(shim::AbstractShim, key) = convert_itemkey(super(shim), key)

@shimmed begin
    getitem(self, key) =
        getindex(self, convert_itemkey(self, key)...)
    setitem!(self, key, value) =
        setindex!(self, value, convert_itemkey(self, key)...)
    delitem!(self, key) =
        delete!(self, convert_itemkey(self, key)...)
end
