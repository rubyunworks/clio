module Clio

  # = Base
  #
  #   class MyCLI < Clio::Base
  #
  #     # Global flag option.
  #     def debug?
  #       @debug = true
  #     end
  #
  #     def remote
  #       ...
  #     end
  #
  #     def remote_verbose?
  #
  #     end
  #
  #     def remote_force?
  #
  #     end
  #
  #     def remote_add(name, branch)
  #
  #     end
  #
  #     def remote_show(name)
  #
  #     end
  #
  #   end
  #
  class Base

    class NoOptionError < ::NoMethodError # ArgumentError ?
      def initialize(name, *arg)
        super("unknown option -- #{name}", name, *args)
      end
    end

    class NoCommandError < ::NoMethodError
      def initialize(name, *args)
        super("unknown command -- #{name}", name, *args)
      end
    end

    class MissingCommandError < ::ArgumentError
      def initialize(*args)
        super("missing command", *args)
      end
    end

    # Used to invoke the command.
    def execute_command(argv=ARGV)
      QuickCLI.run(self, argv)
    end

    # This is the fallback subcommand. Override this to provide
    # a fallback when no command is given on the commandline.
    def command_missing
      raise MissingCommandError
    end

    # Override option_missing if needed.
    # This receives the name of the option and
    # the remaining arguments list. It must consume
    # any argument it uses from the (begining of)
    # the list.
    def option_missing(opt, *argv)
      raise NoOptionError, opt
    end

    class << self

      def run(obj, argv=ARGV)
        args = parse(obj, argv)
        subcmd = args.shift
        if subcmd && !obj.respond_to?("#{subcmd}=")
          begin
            obj.send(subcmd, *args)
          rescue NoMethodError
            raise NoCommandError, subcmd
          end
        else
          obj.command_missing
        end
      end

      #def run(obj)
      #  methname, args = *parse(obj)
      #  meth = obj.method(methname)
      #  meth.call(*args)
      #end

      #
      def parse(obj, argv)
        case argv
        when String
          require 'shellwords'
          argv = Shellwords.shellwords(argv)
        else
          argv = argv.dup
        end

        argv = argv.dup
        args, opts, i = [], {}, 0
        while argv.size > 0
          case opt = argv.shift
          when /=/
            parse_equal(obj, opt, argv, args)
          when /^--/
            parse_option(obj, opt, argv, args)
          when /^-/
            parse_flags(obj, opt, argv, args)
          else
            args << opt
          end
        end
        return args
      end

      #
      def parse_equal(obj, opt, argv, args)
        if md = /^[-]*(.*?)=(.*?)$/.match(opt)
          x, v = md[1], md[2]
        else
          raise ArgumentError, "#{x}"
        end
        if obj.respond_to?("#{x}=")
          obj.send("#{x}=", v)
        elsif obj.respond_to?("#{args.join('_')}_#{x}=")
          obj.send("#{args.join('_')}_#{x}=", v)
        else
          obj.option_missing(x, v) # argv?
        end
        #if obj.respond_to?("#{x}=")
        #  # TODO: to_b if 'true' or 'false' ?
        #  obj.send("#{x}=",v)
        #else
        #  obj.option_missing(x, v) # argv?
        #end
      end

      # TODO: Should we allow more than one argument (ie. arity)
      def parse_option(obj, opt, argv, args)
        x = opt[2..-1] # remove '--'
        if obj.respond_to?("#{x}=")
          m.call(argv.shift)
        elsif obj.respond_to?("#{args.join('_')}_#{x}=")
          m = obj.method("#{args.join('_')}_#{x}=")
          #if m.arity >= 0
          #  a = []
          #  m.arity.times{ a << argv.shift }
          #  m.call(*a)
          #else
          #  m.call
          #end
          m.call(argv.shift)
        elsif obj.respond_to?("#{x}?")
          m = obj.method("#{x}?")
          if m.arity >= 0
            a = []
            m.arity.times{ a << argv.shift }
            m.call(*a)
          else
            m.call
          end
        elsif obj.respond_to?("#{args.join('_')}_#{x}?")
          m = obj.method("#{args.join('_')}_#{x}?")
          if m.arity >= 0
            a = []
            m.arity.times{ a << argv.shift }
            m.call(*a)
          else
            m.call
          end
        else
          obj.option_missing(x, argv)
        end
        #if obj.respond_to?("#{x}=")
        #  obj.send("#{x}=",true)
        #else
        #  obj.option_missing(x, argv)
        #end
      end

      # TODO: this needs some thought concerning character spliting and arguments
      def parse_flags(obj, opt, argv, args)
        x = opt[1..-1]
        c = 0
        x.split(//).each do |k|
          if obj.respond_to?("#{k}?")
            m = obj.method("#{k}?")
            a = []
            m.arity.times{ a << argv.shift }
            m.call(*a)
          else
            obj.option_missing(x, argv)
          end
          #if obj.respond_to?("#{k}=")
          #  obj.send("#{k}=",true)
          #else
          #  obj.option_missing(x, argv)
          #end
        end
      end

    end #class << self

  end

end


=begin :spec:

  require 'quarry/spec'

  class MyCommand < Clio::Command
    attr_reader :size, :quiet, :file

    def initialize
      @file = 'hey.txt' # default
    end

    use :quiet, "supress standard output", :type => :boolean

    def __quiet(bool=true)
      @quiet = bool ? true : bool
    end

    use :size, "what size will it be?", :type => :integer, :default => '0'

    def __size(integer)
      @size = integer.to_i
    end

    use :file, "where to store the stuff", :init => 'hey.txt'

    def __file(fname)
      @file = fname
    end

    def call(*args)
      @args = args
    end
  end

  Quarry.spec "Command" do 
    before do
      @mc = MyCommand.new
    end

    demonstrate 'boolean option' do
      @mc.run(['--quiet'])
      @mc.quiet.assert == true 
    end

    demonstrate 'integer option' do
      @mc.run(['--size=4'])
      @mc.size.assert == 4
    end

    demonstrate 'default value' do
      @mc.run([''])
      @mc.file.assert == 'hey.txt'
    end

    demonstrate 'usage output' do
      MyCommand.usage.assert == "--quiet=BOOLEAN --size=INTEGER --file=VALUE"
    end
  end

=end

