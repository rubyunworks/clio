= Test Subclass of Subclass of Command

Require clio/commandline.rb.

  require 'clio/commandline'

Fake a commandline command.

  $0 = 'c0'

Create new subclass of Clio::Commandline.

  @cmd_super = Class.new(Clio::Commandline) do
    option('o0')
    command('c1').option('o1')
    command('c1 c2').option('o2')
    command('c1 c2').argument('a')
    command('c1 c2').argument('b')
    command('c1 c2').argument('c')
  end

Superclass command display usage string.

  @cmd_super.usage.to_s.assert == 'c0 [--o0] c1 [--o1] c2 [--o2] <a> <b> <c>'

Subclass again.

  @cmd = Class.new(@cmd_super)

Command display usage string.

  @cmd.usage.to_s.assert == 'c0 [--o0] c1 [--o1] c2 [--o2] <a> <b> <c>'

Command initializes.

  @cli = @cmd.new('--o0 c1 --o1 c2 --o2 a b c')

Command is inheritable.

  @cmd2 = Class.new(@cmd)

Inherited command works like parent.

  @cli2 = @cmd2.new('--o0 c1 --o1 c2 --o2 a b c')
  @cli2.parse

Inherited command parsed correctly.

  @cli2.options.assert == {:o0=>true, :o1=>true, :o2=>true}

Method missing options work.

  @cli2.o0?.assert == true
  @cli2.o1?.assert == true
  @cli2.o2?.assert == true

