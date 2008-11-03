Commandline Parsing
===================

Lets take this example commandline, where 'c' stands for command,
'o' for option, 'a' is an ordered argument.

  $ c0 --o1 c1 --o2 c2 --o3 a

First we'll create a quick usage map for it.

  cli = Commandline.new

  cli.usage.option('o0')
  cli.usage.command('c1').option('o1')
  cli.usage.command('c1', 'c2').option('o2')
  cli.usage.command('c1', 'c2').argument('a')

  cli.parser.parse

Then we can parse it in a variety of ways:

  cli[0].name        #=> 'c0'
  cli[0].options     #=> {'o0'=>true }
  cli[0].arguments   #=> []
  cli[0].parameters  #=> ['a0', {'o0'=>true}]
  cli[0].signature   #=> ['c0', 'a0', {'o0'=>true}]

  cli[1].name        #=> 'c1'
  cli[1].options     #=> {'o1'=>true}
  cli[1].arguments   #=> []
  cli[1].parameters  #=> ['a1', {'o1'=>true}]
  cli[1].signature   #=> ['c1', 'a1', {'o1'=>true}]

  cli[2].name        #=> 'c2'
  cli[2].options     #=> {'o2'=>true}
  cli[2].arguments   #=> ['a']
  cli[2].parameters  #=> ['a2', {'o2'=>true}]
  cli[2].signature   #=> ['c2', 'a2', {'o2'=>true}]

  cli.name           #=> ['c0', 'c1', 'c2']
  cli.options        #=> {'o0'=>true, 'o1'=>true, 'o2'=>true}
  cli.arguments      #=> ['a']

  cli.parameters
  #=> [['a', 'b', 'c'], {'o0'=>true, 'o1'=>true, 'o2'=>true}]
  
  cli.signiture
  #=> [['c0', 'c1', 'c2'], ['a', 'b', 'c'], {'o0'=>true, 'o1'=>true, 'o2'=>true}]

  cli.to_a
  #=> [['c0', [], {'o0'=>true}],
       ['c1', [], {'o1'=>true}],
       ['c2', ['a', 'b', 'c'], {'o2'=>true}]]

Commands cannot have both arguments and subcommands. While it is technically
parsable (on older version of Commandline allowed it), when using a command
it proves too easy to accidently omit an argument and have a subcommand take
its place, causing erroneous behavior. I looked through a number of other
commandline tools and never once found a case of subcommands following arguments,
so it was decided to purposely limit Commandline in this fashion.

Currently the Commandline library parses as follows:

  cli.name                        #=> 'c0'
  cli.options                     #=> {'o0'=>true}
  cli.arguments                   #=> ['a0']

  cli.command.name                #=> 'c1'
  cli.command.options             #=> {'o1'=>true}
  cli.command.arguments           #=> ['a1']

  cli.command.command.name        #=> 'c2'
  cli.command.command.options     #=> {'o2'=>true}
  cli.command.command.arguments   #=> ['a2']


Rejected Alternative 
--------------------

An alternative that was consider, was to simplify so there are no "commands",
but just arguments and options. In that case our original example 
becomes effectively:

  $ a0 --o0 a1 a2 --o1 a3 a4 --o2 a5

If we do this however, how would we be able to treat any part of this as a command?
We would need a way simply to "talk" about them as such.

  cli[0]  #=> 'a0'
  cli[1]  #=> 'a1'
  cli[2]  #=> 'a2'
  cli[3]  #=> 'a3'
  cli[4]  #=> 'a4'
  cli[5]  #=> 'a5'

Generally a subcommand depends on the prior command. So we might do something like

  case cli[0]
  when 'a0'
    case cli[1]
    when 'a1'
      cli[1].arguments #=> ['a2', 'a3', 'a4', 'a5', {'o1'=>true 'o2'=>true}]
    end
  end

We still may require the arguments for cli[0] however, but less cli[1]'s. We can
handle that with a Range:

  cli[0..1].arguments #=> [{'o0'=>true}]

This is conceputally much simpler and I dare say I'd prefer it for this reason.
But how does this effect usage? It doesn't make conceptual sense to have an
argument take an option --does it?

  cli.usage.argument('a1').option('o1')

Perhaps it does. Prehaps it simply says, "where we find argument 'a1', the option
'o1' can follow. Maybe so. But usage is descriptive, and in describing commandline
arguments, we think in commands, ordered arguments and options.

However, perhaps we could describe usage in one way and utilize it in another?
Under the hood, a command, and ordered argument and an option are all the same
entity. This was done for the sake of simplicity for the underlying design. The
original classes (one for each type of argument) were not significantly different;
using a single class made them easier to work with and a bit more versitle (albeit
perhaps a little too versitle).

The question is, can the later be made to easily emulate the former. If it can
the simpler solution is the way to go. If not then, the simpiler form may be
easier, but it does not give us the capability of the former. Trying it, we 
quicking discover that the later lacks any way to utilize the command points
from usage. We would need something like:

  a[0..(a.command[1].index)].arguments

And if we did that, we may as well use the former. Which is why this idea was rejected.




