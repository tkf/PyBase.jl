"""
Plain wrapper.

Usage:

```julia
PyCall.PyObject(self::MyModule.MyType) = PyBase.Plain.wrap(self)
```
"""
module Plain

using ..PyBase
using ..PyBase: super
using ..JuliaAPI: JuliaObject, convert_pyindices

struct Shim{T} <: PyBase.AbstractShim
    self::T
end

"""
    PyBase.Plain.wrap(self) :: PyObject
"""
wrap(x::Any) = JuliaObject(Shim(x))

PyBase._unwrap(shim::Shim) = PyBase.super(shim)

end  # module
