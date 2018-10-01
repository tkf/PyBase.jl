const mutated = nothing
# TODO: define a singleton on Python side

_gen_doc(stem, jl) = """
    __$(stem)__(self, other)

Python's $(_pymodelref("__$(stem)__")).
Default implementation is roughly: `broadcast($jl, self, other)`.
"""

_gen_rdoc(stem) = """
    __r$(stem)__(self, other)

Python's $(_pymodelref("__r$(stem)__")).
Default implementation: `PyBase.__$(stem)__(other, self)`.
"""

_gen_idoc(stem, jl) = """
    __i$(stem)__(self, other)

Python's $(_pymodelref("__i$(stem)__")).
If `self` is mutated, `PyBase.mutated` must be returned.
Default implementation:

```julia
function __i$(stem)__(self, other)
    broadcast!($jl, self, self, other)
    return PyBase.mutated
end
```
"""


for (stem, jl) in [
        (:add, +),
        (:sub, -),
        (:mul, *),
        (:truediv, /),
        (:floordiv, ÷),
        (:mod, Base.mod),
        (:pow, ^),
        (:lshift, <<),
        (:rshift, >>),
        (:and, &),
        (:xor, Base.xor),
        (:or, |),
        ]
    py = Symbol(:__, stem, :__)
    @eval $py(a, b) = _wrap(broadcast($jl, a, b))
    @eval $(Symbol(:__r, stem, :__))(a, b) = $py(b, a)
    @eval function $(Symbol(:__i, stem, :__))(a, b)
        broadcast!($jl, a, a, b)
        return mutated
    end
    doc = _gen_doc(stem, jl)
    rdoc = _gen_rdoc(stem)
    idoc = _gen_idoc(stem, jl)
    @eval @doc $doc $py
    @eval @doc $rdoc $(Symbol(:__r, stem, :__))
    @eval @doc $idoc $(Symbol(:__i, stem, :__))
end

__pow__(a, b, modulo) = _wrap(broadcast(powermod, a, b, modulo))

__divmod__(a, b) = (_wrap(broadcast(÷, a, b)),
                    _wrap(broadcast(Base.mod, a, b)))
__rdivmod__(a, b) = __divmod__(b, a)

__matmul__(a, b) = _wrap(a * b)
__rmatmul__(a, b) = __matmul__(b, a)

function __imatmul__(y, a, b)
    if applicable(mul!, y, a, b)
        mul!(y, a, b)
        return mutated
    else
        return _wrap(a * b)
    end
end


for (stem, jl) in [
        (:neg, -),
        (:pos, +),
        (:abs, abs),
        (:invert, ~),
        (:complex, ComplexF64),
        (:int, Int128),
        (:float, Float64),
        # TODO: Use BigFloat/BigInt if mpmath is installed?
        (:trunc, trunc),
        (:floor, floor),
        (:ceil, ceil),
        ]
    py = Symbol(:__, stem, :__)
    @eval $py(a) = _wrap($jl(a))
    doc = """
        __$(stem)__(self)

    Python's $(_pymodelref("__$(stem)__")).
    Default implementation is roughly: `$jl(self)`.
    """
    @eval @doc $doc $py
end


"""
    __round__(self, [ndigits = nothing])

Python's $(_pymodelref("__round__")).
Default implementation is roughly:

```julia
__round__(self) = round(self)
__round__(self, ndigits) = round(self, digits=ndigits)
```
"""
__round__(self) = _wrap(round(self))
__round__(self, ::Nothing) = __round__(self)
__round__(self, ndigits) = _wrap(round(self, digits=ndigits))
