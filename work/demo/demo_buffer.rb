require 'clio/buffer'

out = Clio.buffer

s1 = Clio.string("Left").color(:red)
s2 = Clio.string("Rite").color(:green)

out.split(s1, s2)

out.line('-')

out.table([s1,s2], [s1,s2])

out.list(s1, s2)

out.print

