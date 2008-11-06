= Method Missing "Auto" Usage

Require Commandline library.

    require 'clio/commandline'
    $0 = 'test'

Handles a toplevel option using method_missing.

    cli = Clio::Commandline.new('--verbose')
    cli.verbose?
    cli.to_s.assert == 'test [--verbose]'

Handles a toplevel option with aliases using method_missing.

    cli = Clio::Commandline.new('--verbose')
    cli.verbose?(:v)
    cli.to_s.assert == 'test [-v --verbose]'

Returns a toplevel option value"

    cli = Clio::Commandline.new('--verbose')
    cli.verbose?(:v).assert == true

Create new commandline object.

    cmd = Clio::Commandline.new('--verbose')
    cmd.usage.command('foo')
    cmd.parse

== Single Character Option

Create new Commandline object.

    @cmd = Clio::Commandline.new('-V')

Returns a toplevel option value.

    @cmd.verbose?(:V).assert == true

== Option Literal Shorthand

An option and a subcommand parsed statically.

    $0 = 'test'
    @cli = Clio::Commandline.new('-V foo')
    @cli.usage.opt('--verbose -V')
    @cli.usage.command('foo')
    @cli.parse

Parses the option correctly.

    @cli.options[:verbose].assert == true

QED.

