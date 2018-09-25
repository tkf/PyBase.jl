from ..wrappers import JuliaObject


def test_mimebundle_doc(julia):
    obj = julia.eval("@doc sin")
    assert isinstance(obj, JuliaObject)
    format_dict = obj._repr_mimebundle_()
    mimes = set(format_dict)
    assert mimes >= {
        "text/plain",
        "text/html",
        "text/markdown",
        "text/latex",
    }


def test_mimebundle_pyplot(julia):
    # Isolate the import step so that error message would be clearer:
    julia.eval("import PyPlot")
    obj = julia.eval("""
    let obj = PyPlot.figure()
        PyPlot.plot(1:10)
        obj
    end
    """, wrap=True)
    assert isinstance(obj, JuliaObject)
    format_dict = obj._repr_mimebundle_()
    mimes = set(format_dict)
    assert mimes >= {
        "text/plain",
        "application/pdf",
        "image/png",
    }
