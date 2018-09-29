for (py, jl) in [
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
    @eval $py(a, b) = _wrap(broadcast($jl, a, b))
    @eval $(Symbol(:r, py))(a, b) = $py(b, a)
    @eval function $(Symbol(py, :!))(a, b)
        broadcast!($jl, a, a, b)
        return nothing
    end
end

pow(a, b, modulo) = _wrap(broadcast(powermod, a, b, modulo))

divmod(a, b) = (_wrap(broadcast(÷, a, b)),
                _wrap(broadcast(Base.mod, a, b)))
rdivmod(a, b) = divmod(b, a)

matmul(a, b) = _wrap(a * b)
rmatmul(a, b) = matmul(b, a)

function matmul!(y, a, b)
    if applicable(mul!, y, a, b)
        mul!(y, a, b)
        return nothing
    else
        return _wrap(a * b)
    end
end
