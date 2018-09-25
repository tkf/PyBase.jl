from .wrappers import JuliaObject
from .julia_api import JuliaAPI


def setup(*args, **kwargs):
    global jlapi
    jlapi = JuliaAPI(*args, **kwargs)
