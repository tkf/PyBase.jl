import pytest


@pytest.fixture(scope="session")
def julia(request):
    """ pytest fixture for providing a `JuliaAPI` instance. """
    try:
        from . import jlapi as julia
    except ImportError:
        julia = None
    if julia is None:
        pytest.skip("JuliaAPI is not initialized.")
    # Don't do this when running inside Julia:
    """
    if request.config.getoption("capture") != "no":
        julia.connect_stdio()
    """
    return julia
# JuliaAPI has to be initialized elsewhere (e.g., in top-level conftest.py)


@pytest.fixture(scope="session")
def Main(julia):
    """ pytest fixture for providing a Julia `Main` name space. """
    return julia.Main
