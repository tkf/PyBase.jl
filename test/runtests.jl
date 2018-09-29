using PyBase
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

@test begin
    PyBase.pytest(inprocess = true)
    true
end
