require 'clio/errors'

module Clio

  # = Command
  #
  # Command is Clio's low-level command option parser solution.
  # Despite being low-level, it is actually quite easy to used
  # and integrates will with Ruby.
  #
  # The Command class does not to try overly determine your needs via a
  # declarative options DSL, rather it just makes it easy for you to 
  # process options into a command class. It does this primarily by
  # using a simple method naming trick. Methods with names starting
  # with underscores (eg. _n or __name) are treated as options.
  #
  # Clio::Command encourages the command pattern (hence the name). So one
  # class does one thing and one thing only. This helps ensure a robust
  # design, albeit at the expense of churning a quick all-in-one solution.
  #
  # For a quicker solution to command line parsing have a look at
  # Clio::Commandable or Clio::Commandline.
  #
  # Although it is low-level it does provide a single high-level "DSL"
  # command for describing usage. This is purely a descriptive measure,
  # and has no barring on the functionality. It is provided to ease 
  # the creation of help and command completion output.
  #
  # Simply specify:
  #
  #    usage :optname, "options description", :type=>"TYPE", :default=>"DEFAULT"
  #
  # Here is an example of usage.
  #
  #   MainCommand < Clio::Command
  #
  #     usage :quiet, "keep it quiet?",   :type=>:BOOLEAN, :default=>:FALSE
  #     usage :file,  "what file to use", :type=>:FILE, :alias => :f
  #
  #     # boolean flag
  #     def __quiet
  #       @quiet = true
  #     end
  #
  #     # required option
  #     def __file(fname)
  #       @file = fname
  #     end
  #
  #     # one letter shortcut
  #     alias _f __flag
  #
  #     # run command
  #     def call(*args)
  #       subcommand = args.shift
  #       case subcommand
  #       when 'show'
  #         puts File.read(@file)
  #       when 'rshow'
  #         puts File.read(@file).reverse
  #       else
  #         puts "Unknown subcommand"
  #       end
  #     end
  #
  #   end
  #
  #   MainCommand.run
  #
  # You can chain subcommands together via a case statement like
  # that given above. Eg.
  #
  #       case subcommand
  #       when 'build'
  #         BuildCommand.run(args)
  #       ...
  #
  # TODO: Support passing a string or *args, opts in place of ARGV.
  #
  class QuickCLI

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
        if obj.respond_to?("_#{x}")
          obj.send("_#{x}",v)
        elsif obj.respond_to?("__#{x}")
          obj.send("__#{x}",v)
        elsif obj.respond_to?("#{args.join('_')}_#{x}")
          obj.send("#{args.join('_')}_#{x}",v)
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

      #
      def parse_option(obj, opt, argv, args)
        x = opt[2..-1]
        if obj.respond_to?("__#{x}")
          m = obj.method("__#{x}")
          if m.arity >= 0
            a = []
            m.arity.times{ a << argv.shift }
            m.call(*a)
          else
            m.call
          end
        elsif obj.respond_to?("#{args.join('_')}_#{x}")
          m = obj.method("#{args.join('_')}_#{x}")
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

      #
      def parse_flags(obj, opt, argv, args)
        x = opt[1..-1]
        c = 0
        x.split(//).each do |k|
          if m = obj.method("_#{k}")
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

