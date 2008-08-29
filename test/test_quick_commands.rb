require 'test/unit'
require 'clio/command'

class TestCommand < Test::Unit::TestCase

  ExampleCommand < CLIO::QuickCommand

    def setup
      @check = {}
    end

    # No arguments and no options.
    def a
      @check['a'] = true
    end

    # Takes only options.
    def b(opts)
      @check['b'] = opts
    end

    # Takes multiple arguments and options. (Ruby 1.9 only)
    #def c(*args, opts)
    #end

    # opt 'a', :bolean, 'example option a'

    # Takes one argument and options.
    def d(args, opts)
      @check['d'] = [args, opts]
    end

    def e(args, opts)
      opts.has_only! %w{a b c}    
    end

  end

end

