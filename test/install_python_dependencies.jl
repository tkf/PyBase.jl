module PythonDependencies

const IS_CI = lowercase(get(ENV, "CI", "false")) == "true"
@show IS_CI

if IS_CI
    ENV["MPLBACKEND"] = "agg"
end

using PyCall
conda_packages = [
    "matplotlib",
    "pytest",
    "traitlets"
]
try
    if IS_CI
        for name in conda_packages
            @time PyCall.pyimport_conda(name, name)
        end
    else
        for name in conda_packages
            PyCall.pyimport(name)
        end
    end
catch exception
    @error "Test dependencies not satisfied." exception
end

end  # module
