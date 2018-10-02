#!/bin/bash
# -*- mode: julia -*-
#=
exec ${JULIA:-julia} --color=yes --startup-file=no "${BASH_SOURCE[0]}" "$@"
=#

module TestPyBase

const IS_CI = lowercase(get(ENV, "CI", "false")) == "true"
@show IS_CI

if IS_CI
    ENV["MPLBACKEND"] = "agg"
end

using PyCall
conda_packages = [
    "pytest",
    "traitlets"
]
try
    if IS_CI
        for name in conda_packages
            PyCall.pyimport_conda(name, name)
        end
    else
        for name in conda_packages
            PyCall.pyimport(name)
        end
    end
catch exception
    @error "Test dependencies not satisfied." exception
end

include("preamble.jl")

@testset "$file" for file in [
        "test_ufcs.jl",
        "test_misc.jl",
        "test_pytest.jl",
        ]
    include(file)
end

end  # module
