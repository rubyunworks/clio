= Command Definition using Bracket Notation

Require commandline library.

  require 'clio/commandline'

Since this not a real command line application,
lets fake one called 'test'.

    $0 = 'test'

We can use a method to define a subcommand.

    cmd = Clio::Commandline.new
    cmd.usage['doc']
    cmd.to_s.assert == 'test doc'

We can use a question-method to define a switch.

    cmd = Clio::Commandline.new
    cmd.usage['doc']
    cmd.usage['--verbose']
    cmd.to_s.assert == 'test [--verbose] doc'

The switch method can also take option aliases.

    cmd = Clio::Commandline.new
    cmd.usage['--verbose -v']
    cmd.to_s.assert == 'test [-v --verbose]'

The command can take argument to process as suboptions
and arguments.

    cmd = Clio::Commandline.new
    cmd.usage['doc']['--output=PATH']
    cmd.to_s.assert == 'test doc [--output=PATH]'
    cmd.usage.doc.to_s.assert == 'doc [--output=PATH]'

An option and a subcommand parsed statically.

    cmd = Clio::Commandline.new
    cmd.usage['--verbose -v']
    cmd.usage['doc']['--output=PATH']
    cmd.usage['doc']['<file>']
    cmd.to_s.assert == 'test [-v --verbose] doc [--output=PATH] <file>'

We can define help for these commands and options using
a seaprate help! call.

    cmd = Clio::Commandline.new
    cmd.usage['doc']['--output=PATH']
    cmd.usage['--verbose -v']

    #cmd.usage['doc'] = 'generate documentation'
    #cmd.usage['--verbose -v'] = 'verbose mode'

    cmd.usage.help!(
      'doc', 'generate documentation',
      '--verbose', 'verbose mode'
    )

    cmd.usage.options[0].name.assert == 'verbose'

QED.
