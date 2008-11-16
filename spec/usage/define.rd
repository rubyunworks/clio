= Clio::Usage

== Create a Usage object.

Require usage library.

  require 'clio/usage'

Fake a commandline invocation.

  $0 = 'test'

Create a Usage object.

  usage = Clio::Usage.new

== Basic Notation

Define a usage subcommand using #subcommand.

  usage = Clio::Usage.new
  usage.subcommand('foo')
  usage.to_s.assert == 'test foo'

This is also aliased as #command.

  usage = Clio::Usage.new
  usage.command('foo')
  usage.to_s.assert == 'test foo'

A toplevel switch/option is defined with #option.

  usage = Clio::Usage.new
  usage.option('verbose')
  usage.to_s.assert == 'test [--verbose]'

Options can also have aliases.

  usage = Clio::Usage.new
  usage.option(:verbose, :v)
  usage.to_s.assert == 'test [-v --verbose]'

Arguments are defined with #argument, which takes
a type, or name and type. Multiple arguments can
be defined, and are processed in the order defined.

  usage = Clio::Usage.new
  usage.argument('TYPE')
  usage.argument('alt', 'TYPE2')
  usage.to_s.assert == 'test <TYPE> <alt:TYPE2>'

But arguments can be index to sepcify the index. Argument
index start with 1 (not 0).

  usage = Clio::Usage.new
  usage.argument(1, 'TYPE')
  usage.argument(2, 'alt', 'TYPE2')
  usage.to_s.assert == 'test <TYPE> <alt:TYPE2>'

Final arguments can consume all remaining arguments.
Define this with #splat.

  usage = Clio::Usage.new
  usage.argument('TYPE').splat(true)
  usage.to_s.assert == 'test <TYPE...>'

Usage cannot have both subcommands and arguments.

  usage = Clio::Usage.new
  assert_raises do
    usage.subcommand('foo')
    usage.argument('bar')
  end

Anything define on a Usage object, can also be
defined for a subcommand, since Usage.new actually
returns and subclass of Subcommand.

  usage = Clio::Usage.new
  usage.class.assert < Clio::Subcommand

Bringing it all together in a .

  usage = Clio::Usage.new
  usage.option(:verbose, :v)
  usage.command('foo').argument('TYPE')
  usage.to_s.assert == 'test [-v --verbose] foo <TYPE>'

== Bracket Notation

Subcommand, options and arguments can also be defined using #[].
They are distinighished by syntax used. For instance, to define
a subcommand, use bare syntax.

  usage = Clio::Usage.new
  usage['foo']
  usage.to_s.assert == 'test foo'

To define an option prefix the syntax with '--' or '-', and
aliases are separated by spaces.

  usage = Clio::Usage.new
  usage['--verbose -v']
  usage.to_s.assert == 'test foo'

Arguments are defined by wrapping the type or name:type in < > brackets.

  usage = Clio::Usage.new
  usage['<TYPE>']
  usage.to_s.assert == 'test <TYPE>'


