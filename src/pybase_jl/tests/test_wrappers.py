from __future__ import division

import math

from ..wrappers import JuliaObject

try:
    string_types = (unicode, str)
except NameError:
    string_types = (str,)


def test_peal(Main):
    xs = Main.map(Main.identity, range(3))
    assert all(xs == [0, 1, 2])


def test_wrapped_dict(julia):
    dct = julia.eval("Dict()")
    dct["key"] = "value"
    unwrapped = julia.maybe_unwrap(dct)
    assert unwrapped == {"key": "value"}


def test_unwrapped_dict(julia):
    dct = julia.eval('Dict("a" => 1)', wrap=False)
    assert dct == {"a": 1}


def test_symbol_eval(julia):
    a = julia.eval(":a")
    assert julia.eval("a -> a isa Symbol")(a)


def test_symbol_call(julia):
    a = julia.eval("() -> :a")()
    assert julia.eval("a -> a isa Symbol")(a)


def test_symbol_to_str(julia):
    a = julia.eval(":a")
    assert str(a) == "a"


def test_docstring(julia):
    sin = julia.eval("sin")
    assert isinstance(sin.__doc__, string_types)
    assert "sine" in sin.__doc__


def test_array_contains(julia):
    a = julia.eval('[1, 2, 3]', wrap=True)
    assert 1 in a


def test_numbers(julia):
    one = julia.eval("1", wrap=True)
    two = julia.eval("2", wrap=True)
    six = julia.eval("6", wrap=True)
    five = julia.eval("5", wrap=True)
    assert 2 + 1 == two + 1 == 2 + one == two + one
    assert 2 - 1 == two - 1 == 2 - one == two - one
    assert 2 * 1 == two * 1 == 2 * one == two * one
    assert 2 / 1 == two / 1 == 2 / one == two / one
    assert 2 ** 2 == two ** 2 == 2 ** two == two ** two
    assert 1 << 1 == one << 1 == 1 << one == one << one
    assert 1 >> 1 == one >> 1 == 1 >> one == one >> one
    assert pow(2, 6, 5) == pow(two, six, five)
    assert -1 == -one
    assert +1 == +one
    assert abs(-1) == abs(julia.eval("-1", wrap=True))
    assert ~2 == ~two
    assert isinstance(one.__int__(), int)
    assert isinstance(one.__float__(), float)
    assert isinstance(one.__complex__(), complex)
    assert int(one) == 1
    assert float(julia.eval("1.2", wrap=True)) == 1.2
    assert complex(julia.eval("1 + 2im", wrap=True)) == 1 + 2j
    assert round(julia.eval("1.11111111", wrap=True)) == 1
    assert round(julia.eval("1.11111111", wrap=True), ndigits=3) == 1.111
    assert math.trunc(julia.eval("1.9", wrap=True)) == 1
    assert math.floor(julia.eval("1.9", wrap=True)) == 1
    assert math.ceil(julia.eval("1.1", wrap=True)) == 2


def test_arrays_inplace_binary_ops(julia):
    xs = julia.eval("[1, 1, 1]", wrap=True)
    xs += 1
    assert all(x == 2 for x in xs)

    xs = julia.eval("[1, 1, 1]", wrap=True)
    xs -= 1
    assert all(x == 0 for x in xs)

    xs = julia.eval("[1, 1, 1]", wrap=True)
    xs *= 2
    assert all(x == 2 for x in xs)

    xs = julia.eval("[2, 2, 2]", wrap=True)
    xs /= 2
    assert all(x == 1 for x in xs)

    xs = julia.eval("[1, 1, 1]", wrap=True)
    xs //= 2
    assert all(x == 0 for x in xs)

    xs = julia.eval("[2, 2, 2]", wrap=True)
    xs %= 2
    assert all(x == 0 for x in xs)

    xs = julia.eval("[2, 2, 2]", wrap=True)
    xs **= 2
    assert all(x == 4 for x in xs)

    xs = julia.eval("[1, 1, 1]", wrap=True)
    xs <<= 1
    assert all(x == 2 for x in xs)

    xs = julia.eval("[1, 1, 1]", wrap=True)
    xs >>= 1
    assert all(x == 0 for x in xs)

    xs = julia.eval("[1, 1, 1]", wrap=True)
    xs &= 0
    assert all(x == 0 for x in xs)

    xs = julia.eval("[1, 1, 1]", wrap=True)
    xs ^= 0
    assert all(x == 1 for x in xs)

    xs = julia.eval("[1, 1, 1]", wrap=True)
    xs |= 0
    assert all(x == 1 for x in xs)


def test_missing(julia):
    missing = julia.missing

    def isa_missing(x):
        return julia.eval("===")(x, missing)

    assert isa_missing(missing + 1)
    assert isa_missing(missing - 1)
    assert isa_missing(missing * 1)
    assert isa_missing(missing / 1)
    # assert isa_missing(missing // 1)
    d, r = divmod(missing, 1)
    assert isa_missing(d)
    assert isa_missing(r)
    assert isa_missing(missing % 1)
    assert isa_missing(missing ** 1)


def test_three_valued_logic_left(julia):
    true = julia.eval("true", wrap=True)
    false = julia.eval("false", wrap=True)
    missing = julia.eval("missing")

    def isa_missing(x):
        return julia.eval("===")(x, missing)

    assert isa_missing(true & missing)
    assert not false & missing
    assert true | missing
    assert isa_missing(false | missing)
    assert true ^ False
    assert not true ^ True
    assert isa_missing(true ^ missing)
    assert not false ^ False


def test_three_valued_logic_right(julia):
    true = julia.eval("true", wrap=True)
    false = julia.eval("false", wrap=True)
    missing = julia.eval("missing")

    def isa_missing(x):
        return julia.eval("===")(x, missing)

    assert isa_missing(True & missing)
    assert not False & missing
    assert True | missing
    assert isa_missing(False | missing)
    assert True ^ false
    assert not True ^ true
    assert isa_missing(True ^ missing)
    assert not False ^ false


def test_string_mul(julia):
    a = julia.eval('"a"', wrap=True)
    b = julia.eval('"b"', wrap=True)
    assert a * b == "ab"


def test_bitarray_lshift(julia):
    x = julia.eval("""
    x = BitArray([0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1])
    """)
    actual = x << 2
    desired = julia.eval("x .<< 2")
    assert all(actual == desired)


def test_bitarray_rshift(julia):
    x = julia.eval("""
    x = BitArray([0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1])
    """)
    actual = x >> 2
    desired = julia.eval("x .>> 2")
    assert all(actual == desired)



def test_constructor(julia):
    BitArray = julia.BitArray
    ba = BitArray([1, 0, 1, 0])
    assert isinstance(ba, JuliaObject)


def test_io(julia):
    io = julia.eval("io = IOBuffer()")
    io.write("hello")
    written = julia.eval("String(take!(io))")
    assert written == "hello"


def test_figure(julia):
    from matplotlib.figure import Figure

    # Isolate the import step so that error message would be clearer:
    julia.eval("import PyPlot")

    obj = julia.eval("""
    let obj = PyPlot.figure()
        PyPlot.plot(1:10)
        obj
    end
    """)  # default wrapping behavior

    assert isinstance(obj, Figure)
