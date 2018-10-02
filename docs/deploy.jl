using Documenter

deploydocs(
    repo = "github.com/tkf/PyBase.jl.git",
    julia = "1.0",
    target = "build",
    deps = nothing,
    make = nothing,
)
