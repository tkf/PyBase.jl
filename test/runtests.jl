module TestPyBase

include("preamble.jl")

@testset "$file" for file in [
        "test_ufcs.jl",
        "test_pytest.jl",
        ]
    include(file)
end

end  # module
