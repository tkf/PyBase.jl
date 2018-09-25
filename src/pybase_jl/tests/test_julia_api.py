import io

import pytest

from ..julia_api import banner
from ..wrappers import JuliaObject


def test_object__ipython_canary_method_should_not_exist_(julia):
    obj = julia.Base  # can be any JuliaObject
    assert isinstance(obj, JuliaObject)
    with pytest.raises(AttributeError):
        obj._ipython_canary_method_should_not_exist_
# https://github.com/jupyter/notebook/issues/2014


def test_api__ipython_canary_method_should_not_exist_(julia):
    with pytest.raises(AttributeError):
        julia._ipython_canary_method_should_not_exist_


def test_multiline_eval(julia):
    ans = julia.eval("""
    1
    2
    3
    """)
    assert ans == 3


def test_banner(julia):
    buf = io.StringIO()
    banner(julia, file=buf)
    assert "https://docs.julialang.org" in buf.getvalue()
