module TestMisc

include("preamble.jl")

# The only name crash of Python's double-underscore methods and
# Julia's methods is module-level `__init__`.  Let's make sure to
# never define it since it would be confusing if someone finds that
# `PyBase.__init__` exists and it does not have any effect.  I should
# define it in a dummy submodule if I need it.
@test !isdefined(PyBase, :__init__)

end  # module
