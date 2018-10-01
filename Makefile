JULIA = julia
export JULIA

.PHONY: all test docs

all: test docs

test:
	test/runtests.jl

docs:
	docs/build.jl
