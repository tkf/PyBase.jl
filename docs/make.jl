#!/bin/bash
# -*- mode: julia -*-
#=
JULIA="${JULIA:-julia --color=yes --startup-file=no}"
export JULIA_PROJECT="$(dirname ${BASH_SOURCE[0]})"

set -ex
${JULIA} -e 'using Pkg; Pkg.instantiate();
             Pkg.develop(PackageSpec(path=pwd()))'
exec ${JULIA} "${BASH_SOURCE[0]}" "$@"
=#

include("build.jl")
include("deploy.jl")
