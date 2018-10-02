using Markdown

struct SupportedMethods
    names::Vector{Symbol}
end

SupportedMethods() = SupportedMethods([
    n for n in names(PyBase; all=true) if occursin(r"^__[a-z]+__$", string(n))
])

function Base.show(io::IO, ::MIME"text/markdown", sm::SupportedMethods)
    println(io, "| **Supported method** |")
    println(io, "|:-- |")
    for n in sm.names
        println(io, "| ", _pymodelref(n), " |")
    end
end

function Markdown.MD(sm::SupportedMethods)
    io = IOBuffer()
    show(io, "text/markdown", sm)
    seek(io, 0)
    return Markdown.parse(io)
end

# Base.show(io::IO, sm::SupportedMethods) = show(io, "text/plain", sm)

Base.show(io::IO, mime::MIME"text/plain", sm::SupportedMethods) =
    _show(io, mime, sm)
Base.show(io::IO, mime::MIME"text/html", sm::SupportedMethods) =
    _show(io, mime, sm)

_show(io, mime, sm) = show(io, mime, Markdown.MD(sm))
