require 'quarry/spec'
require 'clio/commandline'

$VERBOSE = true
$DEBUG   = true

Quarry.spec "Commandline" do

  before do
    @cmd = Clio::Commandline.new('--verbose')
    $0 = 'test'
  end

  it "handles a command definition using #command" do
    @cmd.usage.command('foo')
    @cmd.to_s.assert == 'test foo'
  end

  it "handles a command definition using #[]" do
    @cmd.usage['foo']
    @cmd.to_s.assert == 'test foo'
  end

  it "handles a toplevel switch option using #option" do
    @cmd.usage.option('verbose?')
    @cmd.to_s.assert == 'test [--verbose]'
  end

  it "handles a toplevel option using method_missing" do
    @cmd.verbose?
    @cmd.to_s.assert == 'test [--verbose]'
  end

  it "handles a toplevel switch option with aliases using #option" do
    @cmd.verbose?(:V)
    @cmd.to_s.assert == 'test [--verbose | -V]'
  end

  it "handles a toplevel option with aliases using method_missing" do
    @cmd.verbose?(:V)
    @cmd.to_s.assert == 'test [--verbose | -V]'
  end

  it "returns a toplevel option value" do
    @cmd.verbose?(:V).assert == true
  end

end

