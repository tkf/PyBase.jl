module Plain

using ..PyBase
using ..PyBase: super
using ..JuliaAPI: JuliaObject, convert_pyindices

struct Shim{T} <: PyBase.AbstractShim
    self::T
end

wrap(x::Any) = JuliaObject(Shim(x))

PyBase._unwrap(shim::Shim) = PyBase.super(shim)

end  # module
