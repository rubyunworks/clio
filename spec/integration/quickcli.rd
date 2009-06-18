Require QuickCLI class.

  require 'clio/quickcli'

Setup an example CLI subclass.

  class MyCLI < Clio::QuickCLI

    attr :result

    def initialize
      @result = []
      super
    end

    def clear!
      @result = []
    end

    def c1
      @result << "c1"
    end

    def c1_o1(value)
      @result << "c1_o1 #{value}"
    end

    def c1_o2(value)
      @result << "c1_o2 #{value}"
    end

    def c2
      @result << "c2"
    end

    def c2_o1(value)
      @result << "c2_o1 #{value}"
    end

    def c2_o2
      @result << "c2_o2"
    end

    def _g
      @result << "g"
    end
  end

Instantiate and run the class on an example command line.

  cli = MyCLI.new

  before {
    cli.clear!
  }

Just a command.

  cli.execute_command('c1')
  cli.result.should == ['c1']

Command with global option.

  cli.execute_command('c1 -g')
  cli.result.should == ['g', 'c1']

Command with option.

  cli.execute_command('c1 --o1 A')
  cli.result.should == ['c1_o1 A', 'c1']

Command with two options.

  cli.execute_command('c1 --o1 A --o2 B')
  cli.result.should == ['c1_o1 A', 'c1_o2 B', 'c1']

Try out the second command.

  cli.execute_command('c2')
  cli.result.should == ['c2']

Command with option.

  cli.execute_command('c2 --o1 A')
  cli.result.should == ['c2_o1 A', 'c2']

Command with two options.

  cli.execute_command('c2 --o1 A --o2')
  cli.result.should == ['c2_o1 A', 'c2_o2', 'c2']

Let try to confuse it.

  cli.execute_command('c1 c2 --o1 A --o2')
  cli.result.should == ['c2_o1 A', 'c2_o2', 'c2']

How about a non-existenct method.

  cli.execute_command('q')
  cli.result.should == ['q']

How about an option only.

  cli.execute_command('-g')
  cli.result.should == ['-g']

QED.

