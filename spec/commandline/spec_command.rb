require 'quarry/spec'

Quarry.spec "Command class works as expected" do

  given do
    require 'clio/command'
    $0 = 'c0'
    @cmd = Class.new(Clio::Command) do
      option('o0')
      command('c1').option('o1')
      command('c1','c2').option('o2')
      command('c1','c2').argument('a')
      command('c1','c2').argument('b')
      command('c1','c2').argument('c')
    end
  end

  prove "Command display usage string" do
    @cmd.usage.to_s.assert == 'c0 [--o0] c1 [--o1] c2 [--o2] <a> <b> <c>'
  end

  prove "Command initializes" do
    @cli = @cmd.new('--o0 c1 --o1 c2 --o2 a b c')
  end

  prove "Command is inheritable" do
    @cmd2 = Class.new(@cmd)
  end

  prove "Inherited command works like parent" do
    @cli2 = @cmd2.new('--o0 c1 --o1 c2 --o2 a b c')
    @cli2.parse
  end

  prove "Inherited command parsed correctly" do
    @cli2.options.assert == {:o0=>true, :o1=>true, :o2=>true}
  end

end

