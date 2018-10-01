#!/bin/bash
# -*- mode: julia -*-
#=
exec ${JULIA:-julia} --color=yes --startup-file=no "${BASH_SOURCE[0]}" "$@"
=#

using Documenter
using PyBase

makedocs(
    sitename = "PyBase.jl",
    repo = "https://github.com/tkf/PyBase.jl/blob/{commit}{path}#{line}",
    format = :html,
    doctest = true,
    # strict = true,
)
