= Usage Parsing

Require usage library.

  require 'clio/usage'

A single toplevel option.

  usage = Clio::Usage.new
  usage.option('force')
  cli = usage.parse('--force')

  cli.options.assert == {:force=>true}

A single toplevel option with an alias.

  usage = Clio::Usage.new
  usage.option('force', 'f')
  cli = usage.parse('-f')

  cli.options.assert == {:force=>true}

A subcommand.

  usage = Clio::Usage.new
  usage.command('foo')
  cli = usage.parse('foo')

  cli.command.assert == 'foo'
  cli.commands.assert == ['foo']

A subcommand with an option.

  usage = Clio::Usage.new
  usage.command('foo')
  usage.command('foo').option('verbose')
  cli = usage.parse('foo --verbose')

  cli.command.assert == 'foo'
  cli.commands.assert == ['foo']
  cli.options.assert == {:verbose=>true}

  cli[0].options.assert == {}
  cli[1].options.assert == {:verbose=>true}

QED.

