= Usage Definition

Require commandline library.

  require 'clio/usage'
  $0 = 'test'

Create a Usage object.

  usage = Clio::Usage.new

Handles a command definition using #command.

  usage = Clio::Usage.new
  usage.command('foo')
  usage.to_s.assert == 'test foo'

Handles a command definition using #[].

  #usage = Clio::Usage.new
  #usage['foo']
  #usage.to_s.assert == 'test foo'

Handles a toplevel switch/option using #option.

  usage = Clio::Usage.new
  usage.option('verbose?')
  usage.to_s.assert == 'test [--verbose]'

Handles a toplevel switch/option with aliases using #option.

  usage = Clio::Usage.new
  usage.option(:verbose?, :v)
  usage.to_s.assert == 'test [-v --verbose]'

An option and a subcommand.

  usage = Clio::Usage.new
  usage.opt('--verbose -v')
  usage.command('foo')
  usage.to_s.assert == 'test [-v --verbose] foo'

QED.

