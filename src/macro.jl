using MacroTools

"""
Expand:

    f(x, ...) = ...

Into:

    f(x, ...) = ...
    f(x::AbstractShim, ...) = f(super(x), ...)
"""
function inject_shim(ex)
    ex = shortdef(ex)
    if ex.head == :block
        exprs = ex.args
    else
        exprs = [ex]
    end
    return Expr(:block, Iterators.flatten(inject_shim1.(exprs))...)
end

function inject_shim1(ex)
    if @capture(ex, ((f_(all_args__; kwargs__))|f_(all_args__)) = body__)
        all_args = Expr(:tuple, all_args...)
        if @capture(all_args, (((self_::T_)|self_), args__))
        elseif @capture(all_args, ((self_::T_)|self_))
            args = []
        else
            error("Unexpected: $all_args")
        end
        if self isa Vector && length(self) == 1
            self, = self
        end
        if kwargs === nothing
            kwargs = []
        end
        return [
            ex,
            :($f($self::AbstractShim, $(args...); $(kwargs...)) =
              $f(super($self), $(args...); $(kwargs...))),
        ]
    else
        return [ex]
    end
end

macro shimmed(ex)
    esc(inject_shim(ex))
end
