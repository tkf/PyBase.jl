include("preamble.jl")

@test begin
    PyBase.pytest(inprocess = true)
    true
end
