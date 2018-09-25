#!/bin/bash
# -*- mode: julia -*-
#=
# A hack to pass default options to julia:
exec julia --project --color=yes --startup-file=no "${BASH_SOURCE[0]}" "$@"
=#

#=
CLI to run pytest within Julia process.

All arguments are passed to pytest.

Examples:

    cd HERE
    ./pytest.jl
    ./pytest.jl -x --pdb
    ./pytest.jl pybase_jl/tests/test_wrappers.py
=#

# Do not use matplotlib GUI backend during tests.
ENV["MPLBACKEND"] = "agg"

using PyBase
code = PyBase.pytest(
    `$ARGS`;
    inprocess = true,
    # revise = false,
    check = false,
)
exit(code)
