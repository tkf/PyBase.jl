module Plain

using ..PyBase
using ..PyBase: super
using ..JuliaAPI: JuliaObject, convert_pyindices

struct Shim{T} <: PyBase.AbstractShim
    self::T
end

wrap(x::Any) = JuliaObject(Shim(x))

PyBase._unwrap(shim::Shim) = PyBase.super(shim)

function (shim::Shim)(args...; kwargs...)
    return super(shim)(args...; kwargs...)
end

end  # module
