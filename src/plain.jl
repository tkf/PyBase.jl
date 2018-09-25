module Plain

using ..PyBase
using ..PyBase: super
using ..JuliaAPI: JuliaObject, convert_pyindices, _unwrap

struct Shim{T} <: PyBase.AbstractShim
    self::T
end

wrap(x::Any) = JuliaObject(Shim(x))

function (shim::Shim)(args...; kwargs...)
    return super(shim)(args...; kwargs...)
end

end  # module
