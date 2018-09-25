module JuliaAPI

using Dates

using PyCall
using PyCall: pyjlwrap_new
using Requires

using ..PyBase

const NpyNumber = Union{
    (t for t in values(PyCall.npy_typestrs) if t <: Number)...
}


_wrap(obj::Any) = pyjlwrap_new(obj)
# Wrap the object if it is desirable to _not_ invoke PyCall's
# automatic conversion.

_wrap(obj::Union{
    Nothing,
    Integer,
    NpyNumber,            # to exclude ForwardDiff.Dual etc.
    Array{<: NpyNumber},  # ditto
    AbstractString,  # should it be just String?
    Dates.AbstractTime,
    IO,
}) = obj
# It's OK to include some types that are not supported PyCall.  In
# that case, those objects are passed through pyjlwrap_new anyway.
# What should be avoided here is to include some types that would be
# converted by PyCall in an irreversible manner (e.g., Symbol,
# BitArray, etc.).

_unwrap(x::Any) = x
_unwrap(shim::PyBase.AbstractShim) = PyBase.super(shim)


"""
    wrapcall(f, args...; kwargs...)

Wrap what `f(args...; kwargs...)` returns.
"""
function wrapcall(f, args...; kwargs...)
    return _wrap(f(args...; kwargs...))
    #=
    _f = _unwrap(f)
    _args = _unwrap.(args)
    _kwargs = (k => _unwrap(v) for (k, v) in kwargs)
    return _wrap(_f(_args...; _kwargs...))
    =#
end


struct WrappingCallback
    o::PyObject
    force::Bool
end

function (f::WrappingCallback)(args...; kwargs...)
    wrap = f.force ? pyjlwrap_new : _wrap
    return f.o(wrap.(args)...; (k => wrap(v) for (k, v) in kwargs)...)
end


struct _jlwrap_type end  # a type that would be wrapped as jlwrap by PyCall

get_jlwrap_prototype() = _jlwrap_type()

pybroadcast(op::String, args...) =
    _pybroadcast(eval(Meta.parse(strip(op))), args...)
pybroadcast(op, args...) = _pybroadcast(op, args...)
_pybroadcast(op, args::AbstractArray...) = op.(args...)
_pybroadcast(op, args...) = op(args...)

struct PySlice
    start
    stop
    step
end

struct PyEllipsis end

PyBase.convert_itemkey(self, key) = convert_pyindices(self, key)

function convert_pyindices(x, indices)
    if applicable(firstindex, x, 1)
        # arrays
        return convert_pyindex.((x,),
                                process_pyindices(ndims(x), indices),
                                1:length(indices))
    elseif indices isa Tuple{Integer} && applicable(firstindex, x)
        # tuples, etc.
        return (firstindex(x) + indices[1],)
    else
        # dictionaries, etc.
        return indices
    end
end

function process_pyindices(nd, indices)
    colons = repeat([:], inner=nd - length(indices))
    i = findfirst(i -> i isa PyEllipsis, indices)
    if i === nothing
        return (indices..., colons...)
    else
        return (indices[1:i - 1]..., colons..., ndices[i + 1:end]...)
    end
end

convert_pyindex(x, i, ::Int) = i

convert_pyindex(x, i::Integer, d::Int) = firstindex(x, d) + i

function convert_pyindex(x, slice::PySlice, d::Int)
    start = (slice.start === nothing ? 0 : slice.start) + firstindex(x, d)
    stop = slice.stop === nothing ? lastindex(x, d) : slice.stop + 1
    step = slice.step === nothing ? 1 : slice.step
    if step == 1
        return start:stop
    else
        return start:step:stop
    end
end


function eval_str(code::AbstractString;
                  scope::Module = Main,
                  filename::AbstractString = "string",
                  auto_jlwrap = true,
                  force_jlwrap = false)
    result = include_string(scope, code, filename)
    if force_jlwrap
        return pyjlwrap_new(result)
    elseif auto_jlwrap
        return _wrap(result)
    end
    return result
end


const JuliaObject = PyNULL()

function __init__()
    # Setup Python package `pybase_jl`:
    pushfirst!(PyVector(pyimport("sys")["path"]), @__DIR__)
    pybase_jl = pyimport("pybase_jl")
    pybase_jl[:setup](eval_str, JuliaAPI)
    copy!(JuliaObject, pybase_jl[:JuliaObject])

    # Don't wrap JuliaPy wrappers
    @require Pandas="eadc2687-ae89-51f9-a5d9-86b5a6373a9c" @eval begin
        _wrap(obj::Pandas.PandasWrapped) = obj
    end
    @require SymPy="24249f21-da20-56a4-8eb1-6a02cf4ae2e6" @eval begin
        _wrap(obj::SymPy.SymbolicObject) = obj
    end
    @require PyPlot="d330b81b-6aea-500a-939a-2ce795aea3ee" @eval begin
        _wrap(obj::PyPlot.Figure) = obj
    end
end


"""
    pytest([args::Cmd]; inprocess=true)
"""
function pytest(args=``; inprocess=true,
                cwd = @__DIR__,
                kwargs...)
    cd(cwd) do
        if inprocess
            pytest_inprocess(args; kwargs...)
        else
            pytest_cli(args)
        end
    end
end

function pytest_inprocess(args; check=true)
    @info `pytest $args`
    code = pyimport("pytest")[:main](collect(args))
    if !check
        return code
    end
    if code != 0
        error("$(`pytest $args`) failed with code $code")
    end
end

function pytest_cli(args)
    command = `$(PyCall.pyprogramname) -m pytest $args`
    @info command
    run(command)
end

end  # module

using .JuliaAPI: pytest
