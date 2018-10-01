def test_ufcs_struct(julia):
    MyType = julia.eval("""Base.eval(Module(), quote
    using PyCall
    using PyBase

    mutable struct MyType
        x::Number
    end

    PyCall.PyObject(self::MyType) = PyBase.UFCS.wrap(self)

    # Those methods have to be automatically treated via UFCS
    add1!(self::MyType) = self.x += 1

    add2(self::MyType) = self.x + 2

    add3(self::MyType) = self.x + 3
    add3!(self::MyType) = self.x += 3

    PyBase.__getattr__(self::MyType, ::Val{:explicit_method}) =
        (arg) -> ("explicit method call", self, arg)

    MyType
    end)""", wrap=False)

    obj = MyType(0)
    obj.add1()
    assert obj.x == 1

    assert obj.add2() == 3
    assert obj.x == 1

    assert obj.add3(inplace=False) == 4
    assert obj.x == 1

    obj.add3()  # default to inplace=True
    assert obj.x == 4

    assert {"add1", "add2", "add3"} <= set(dir(obj))
