== Commandline Parsing

Require command library.

  require 'clio/commandline'

A single toplevel option.

  cmd = Clio::Commandline.new
  cmd.usage.option('force')
  cmd.parse('--force')
  cmd.options.assert == {:force=>true}

A single toplevel option with an alias.

  cmd = Clio::Commandline.new
  cmd.usage.option('force', 'f')
  cmd.parse('-f')
  cmd.options.assert == {:force=>true}

A subcommand.

  cmd = Clio::Commandline.new
  cmd.usage.command('foo')
  cmd.parse('foo')
  cmd.command.assert == 'foo'
  cmd.commands.assert == ['foo']

A subcommand with an option.

  cmd = Clio::Commandline.new
  cmd.usage.command('foo')
  cmd.usage.command('foo').option('verbose')
  cmd.parse('foo --verbose')

  cmd.command.assert == 'foo'
  cmd.commands.assert == ['foo']
  cmd.options.assert == {:verbose=>true}

  cmd[0].options.assert == {}
  cmd[1].options.assert == {:verbose=>true}

Multiple subcommands.

  cmd = Clio::Commandline.new
  cmd.usage.command('foo').command('bar').option('verbose')
  cmd.parse('foo bar --verbose')

  cmd.command.assert == 'foo bar'
  cmd.commands.assert == ['foo','bar']
  cmd.options == {:verbose=>true}

  cmd[0].options.assert == {}
  cmd[1].options.assert == {}
  cmd[2].options.assert == {:verbose=>true}

Multiple subcommands.

  cmd = Clio::Commandline.new
  cmd.usage.command('foo').option('verbose')
  cmd.usage.command('foo bar')
  cmd.parse('foo bar --verbose')

  cmd.command.assert == 'foo bar'
  cmd.commands.assert == ['foo','bar']
  cmd.options == {:verbose=>true}

  cmd[0].options.assert == {}
  cmd[1].options.assert == {}
  cmd[2].options.assert == {:verbose=>true}

