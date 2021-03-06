module TestUFCS

include("preamble.jl")
using PyBase.UFCS: MethodShim, DualMethodShim


module MyModule
mutable struct MyType
    x::Number
end

add1!(self::MyType) = self.x += 1;

add2(self::MyType) = self.x + 2;

add3(self::MyType) = self.x + 3
add3!(self::MyType) = self.x += 3;
end  # module

using .MyModule: MyType


@testset "show" begin
    self = PyBase.UFCS.Shim(MyType(0))

    for shim in [PyBase.__getattr__(self, :add1),
                 PyBase.__getattr__(self, :add2)]
        @test shim isa MethodShim
        @test occursin("[shim] ", string(shim))
    end

    let shim = PyBase.__getattr__(self, :add3)
        @test shim isa DualMethodShim
        @test occursin("[shim] ", string(shim))
        @test occursin(" | ", string(shim))
    end
end


@testset "__dir__" begin
    self = PyBase.UFCS.Shim(MyType(0))
    members = PyBase.__dir__(self)
    @test Set(["add1", "add2", "add3"]) <= Set(members)
end


end  # module
