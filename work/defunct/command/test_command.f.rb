require 'facets/command'

require 'test/unit'
require 'stringio'

include Console

class TestCommand < Test::Unit::TestCase
  Output = []

  def setup
    Output.clear
    $stderr = StringIO.new
  end

  # Base test command (in case we wnat ot share something).

  class TestCommand < Command
  end

  #
  # Test basic command.
  #

  class SimpleCommand < TestCommand
    def here! ; @here = true ; end

    def main(*args)
      Output.concat([@here] | args)
    end
  end

  def test_SimpleCommand
    cmd = SimpleCommand.new
    cmd.execute( '--here file1 file2' )
    assert_equal( [true, 'file1', 'file2'], Output )
  end

  #
  # Test missing subcommand.
  #

  class CommandWithMethodMissingSubcommand < TestCommand
    def here! ; @here = true ; end

    def method_missing(cmd, *args)
      Output.concat([@here, cmd] | args)
    end
  end

  def test_CommandWithMethodMissingSubcommand
    cmd = CommandWithMethodMissingSubcommand.new
    cmd.execute( '--here go file1' )
    assert_equal( [true, :go, 'file1'], Output )
  end

  #
  # Test simple subcommand.
  #

  class CommandWithSimpleSubcommand < TestCommand
    def here! ; @here = true ; end

    options :go do
      attr :i
      def i=(n)
        @i = n.to_i
      end
    end

    def go
      Output.concat([@here, @options.i])
    end
  end

  def test_CommandWithSimpleSubcommand
    cmd = CommandWithSimpleSubcommand.new
    cmd.execute( '--here go -i 1' )
    assert_equal( [true, 1], Output )
  end

  #
  # Global options can be anywhere, right? Even after subcommands?
  #

  class CommandWithGlobalOptionsAfterSubcommand < TestCommand
    global_option :x

    def x! ; @x = true ; end

    options :go do
      attr :i
      def i=(n)
        @i = n.to_i
      end
    end

    def go ; Output.concat([@x, @options.i]) ; end
  end

  def test_CommandWithGlobalOptionsAfterSubcommand_01
    cmd = CommandWithGlobalOptionsAfterSubcommand.new
    cmd.execute( 'go -x -i 1' )
    assert_equal( [true, 1], Output )
  end

  def test_CommandWithGlobalOptionsAfterSubcommand_02
    cmd = CommandWithGlobalOptionsAfterSubcommand.new
    cmd.execute( 'go -i 1 -x' )
    assert_equal( [true, 1], Output )
  end

  #
  #
  #

  class GivingUnrecognizedOptions < TestCommand
    def x! ; @x = true ; end
    def go ; Output.concat([@x, @p]) ; end
  end

  def test_GivingUnrecognizedOptions
    cmd = GivingUnrecognizedOptions.new
    assert_raise(InvalidOptionError) do
      cmd.execute( '--an-option-that-wont-be-recognized -x go' )
    end
    #assert_equal "Unknown option '--an-option-that-wont-be-recognized'.\n", $stderr.string
    assert_equal( [], Output )
  end

  #
  #
  #

  class PassingMultipleSingleCharOptionsAsOneOption < TestCommand
    def x! ; @x = true ; end
    def y! ; @y = true ; end
    def z=(n) ; @z = n ; end

    global_option :x

    options :go do
      attr :i
      def i=(n)
        @i = n.to_i
      end
    end

    def go ; Output.concat([@x, @y, @z, @options.i]) ; end
  end

  def test_PassingMultipleSingleCharOptionsAsOneOption
    cmd = PassingMultipleSingleCharOptionsAsOneOption.new
    cmd.execute( '-xy -z HERE go -i 1' )
    assert_equal( [true, true, 'HERE', 1], Output )
  end

#   #
#
#   class CommandWithOptionUsingEquals < TestCommand
#     subcommand :go do
#       def __mode(mode) ; @mode = mode ; end
#       def main ; Output.concat([@mode]) ; end
#     end
#   end
#
#   def test_CommandWithOptionUsingEquals
#     cmd = CommandWithOptionUsingEquals.new
#     cmd.execute( 'go --mode smart' )
#     assert_equal( ['smart'], Output )
#
#     # I would expect this to work too, but currently it doesn't.
#     #assert_nothing_raised { CommandWithOptionUsingEquals.execute( 'go --mode=smart' ) }
#     #assert_equal( ['smart'], Output )
#   end

  #

  class CommandWithSubcommandThatTakesArgs < TestCommand
    def go(arg1, *args) ; Output.concat([arg1] | args) ; end
  end

  def test_CommandWithSubcommandThatTakesArgs
    cmd = CommandWithSubcommandThatTakesArgs.new
    cmd.execute( 'go file1 file2 file3' )
    assert_equal( ['file1', 'file2', 'file3'], Output )
  end

  #

  class CommandWith2OptionalArgs < TestCommand
    def here! ; @here = true ; end

    options :go do
      attr :i
      def i=(n)
        @i = n.to_i
      end
    end

    def go(required1 = nil, optional2 = nil)
      Output.concat [@here, @options.i, required1, optional2]
    end
  end

  def test_CommandWith2OptionalArgs
    cmd = CommandWith2OptionalArgs.new
    cmd.execute( '--here go -i 1 to' )
    assert_equal( [true, 1, 'to', nil], Output )
  end

  #

  class CommandWithVariableArgs < TestCommand
    def here! ; @here = true ; end

    options :go do
      attr :i
      def i=(n)
        @i = n.to_i
      end
    end

    def go(*args) ; Output.concat([@here, @options.i] | args) ; end
  end

  def test_CommandWithVariableArgs
    cmd = CommandWithVariableArgs.new
    cmd.execute( '--here go -i 1 to bed' )
    assert_equal( [true, 1, 'to', 'bed'], Output )
  end

  #

  class CommandWithOptionMissing < TestCommand
    def here! ; @here = true ; end

    options :go do
      attr :i
      def option_missing(opt, value)
        case opt
        when '-i'
          @i = value.to_i
          true
        else
          super
        end
      end
    end

    def go(*args) ; Output.concat([@here, @options.i] | args) ; end
  end

  def test_CommandWithOptionMissing
    cmd = CommandWithOptionMissing.new
    cmd.execute( '--here go -i 1 to bed right now' )
    assert_equal( [true, 1, 'to', 'bed', 'right', 'now'], Output )
  end

end


class TestCommandOptions < Test::Unit::TestCase

  class MyOptions < Command::Options
    attr_reader :a, :b
    def a! ; @a = true ; end
    def b=(x) ; @b = x ; end
  end

  def test_myoptions1
    opts = MyOptions.parse("-a -b hi")
    assert_equal( true, opts.a)
  end

  def test_myoptions2
    opts = MyOptions.parse("-a -b hi")
    assert_equal('hi', opts.b)
  end

  def test_usage
    opts = MyOptions.parse("-a -b hi")
    assert_equal('[-a] [-b value]', opts.usage)
  end

end
