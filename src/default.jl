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
        return nothing
    end
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
        return nothing
    else
        return _wrap(a * b)
    end
end
