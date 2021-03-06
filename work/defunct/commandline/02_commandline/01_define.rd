= Commandline Definition

== Core Notation

Require commandline library.

  require 'clio/commandline'

Fake that we running an executable called 'test'.

    $0 = 'test'

Create a new commandline object.

    @cmd = Clio::Commandline.new

We can define a subcommand using #command on #usage.

    @cmd.usage.command('foo')
    @cmd.to_s.assert == 'test foo'

We can define a toplevel switch using #switch.

    @cmd.usage.switch('verbose')
    @cmd.to_s.assert == 'test [--verbose] foo'

Switches can have aliases.

    @cmd.usage.switch(:verbose, :v)
    @cmd.to_s.assert == 'test [-v --verbose] foo'

There can be mulitple subcommands.

    @cmd.usage.command('foo bar')
    @cmd.to_s.assert == 'test [-v --verbose] foo bar'

Let's bring it all together in one example.

    cmd = Clio::Commandline.new
    cmd.usage.switch(:verbose, :v)
    cmd.usage.switch(:force, :f)
    cmd.usage.command('foo')
    cmd.usage.command('bar')
    cmd.to_s.assert == 'test [-v --verbose] [-f --force] [foo | bar]'

