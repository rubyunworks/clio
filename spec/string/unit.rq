= Clio::String

Require the Clio String library.

    require 'clio/string'

Define a fest regular strings.

    @s1 = "Hi how are you."
    @s2 = "Fine thanks."

Define the equivalent Clio strings.

    @c1 = Clio.string("Hi how are you.")
    @c2 = Clio.string("Fine thanks.")

Applying #color apps the red ANSI code.

    r = @c1.color(:red)
    e = Clio::ANSICode.red(@s1)
    e.assert == r.to_s

non-in-place delegation

    r = @c1.upcase
    e = @s1.upcase
    e.assert == r.to_s

string addition

    r = @c1 + @c2
    e = @s1 + @s2
    e.assert == r.to_s

string single index

    r = @c1[0]
    e = @s1[0,1]
    e.assert == r.to_s

string size index

    r = @c1[0,3]
    e = @s1[0,3]
    e.assert == r.to_s

string range index

    r = @c1[0..3]
    e = @s1[0..3]
    e.assert == r.to_s

Method #sub can replace a substring.

    r = @c1.sub('Hi', 'Hello')

QED.

