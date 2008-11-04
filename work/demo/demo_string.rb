require 'clio/string'

s1 = Clio.string("Left").color(:red)
s2 = Clio.string("Right").color(:green)

s = (s1 | s2)

s.print

