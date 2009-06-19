== Commandline Tab Completion

Load commandline library.

  require 'clio/commandline'

Create a new command line object.

  $0 = 'c0'
  @cli = Clio::Commandline.new

Specify usage for comamndline.

  @cli.usage.option('o0')
  @cli.usage.command('c1').opt('--o1=TYPE -o')
  @cli.usage.command('c1 c2').option('o2')
  @cli.usage.command('c1 c2').argument('a')
  @cli.usage.command('c1 c2').argument('b')
  @cli.usage.command('c1 c2').argument('c')

First lets make sure it parses okay.

  @cli.parse('--o0 c1 --o1 atype c2 --o2 a b c')

Now let try some tab completion. First a command.

  #@cli.parse('c1 -')
  @cli.completion('c1').assert == ['-o --o1=TYPE', 'c2']

Now an option.

  @cli.completion('c1 --o1').assert == ["TYPE"]




