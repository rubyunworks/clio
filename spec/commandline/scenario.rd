= Commandline Parses Correctly

Load commandline library.

    require 'clio/commandline'

Create a new command line object.

    $0 = 'c0'
    @cli = Clio::Commandline.new('--o0 c1 --o1 c2 --o2 a b c')

Specify usage for comamndline.

    @cli.usage.option('o0')
    @cli.usage.command('c1').option('o1')
    @cli.usage.command('c1 c2').option('o2')
    @cli.usage.command('c1 c2').argument('a')
    @cli.usage.command('c1 c2').argument('b')
    @cli.usage.command('c1 c2').argument('c')

    #@cli.usage.option('o0')
    #@cliusage.argument('a0')
    #@cli.usage.command('c1').option('o1')
    #@cli.usage.command('c1').argument('a1')
    #@cli.usage.command('c1').command('c2').option('o2')
    #@cli.usage.command('c1').command('c2').argument('a2')

Usage string is correct.

    @cli.to_s.assert == 'c0 [--o0] c1 [--o1] c2 [--o2] <a> <b> <c>'

Parses without error.

    @cli.parse

Full signature is correct.

    @cli.to_a.assert == [
      ["c0", [], {:o0=>true}],
      ["c1", [], {:o1=>true}],
      ["c2", ["a", "b", "c"], {:o2=>true}]
    ]

Options provides all options merged together.

    @cli.options.assert == {:o0=>true,:o1=>true,:o2=>true}

Switches method is an alias for options.

    @cli.switches.assert == {:o0=>true,:o1=>true,:o2=>true}

Arguments provides all concated together.

    @cli.arguments.assert == ["a", "b", "c"]

Parameters method provides arguments and options.

    @cli.parameters.assert == ["a", "b", "c", {:o0=>true,:o1=>true,:o2=>true}]

Zeroth signature is correct.

    @cli[0].command.assert == 'c0'
    @cli[0].options.assert == {:o0=>true}
    @cli[0].arguments.assert == []
    @cli[0].parameters.assert == [{:o0=>true}]
    @cli[0].signature.assert == ["c0", [], {:o0=>true}]
    @cli[0].to_a.assert == ["c0", [], {:o0=>true}]

First signature is correct.

    @cli[1].to_a.assert == ["c1", [], {:o1=>true}]

Second signature is correct.

    @cli[2].to_a.assert == ["c2", ["a", "b", "c"], {:o2=>true}]

There are no more signatures after the second.

    @cli[3].assert == nil

QED.
