require 'clio/commandline'
#require 'shellwords'

module Clio

  # = AutoCommandline
  #
  # Clio's AutoCommandline is a subclass of Commandline.
  # It can be used lazily, whereby information about usage
  # is built-up as the Commandline object gets use in
  # one's program.
  #
  # See Commandline for underlying implementation.
  #
  # == Passive Parsing
  #
  # The AutoCommandline class allows you to declare as little or as
  # much of the commandline interface upfront as is suitable to
  # your application. When using an AutoCommandline object, if not
  # already defined, options will be lazily created. For example:
  #
  #   cli = Clio::AutoCommandline.new('--force')
  #   cli.force?  #=> true
  #
  # Commandline sees that you expect a '--force' flag to be an
  # acceptable option becuase you asked for it with #force?.
  # So it will call cli.usage.option('force') behind the scenes
  # before trying to determine the actual value per the content
  # of the command line. You can add aliases as parameters to
  # this call as well.
  #
  #   cli = Clio::AutoCommandline.new('-f')
  #   cli.force?(:f)  #=> true
  #
  # Once set, you do not need to specify the alias again:
  #
  #   cli.force?      #=> true
  #
  # With the exception of help information, this means you can
  # generally just use a commandline as needed without having
  # to declare anything upfront, which can be very useful for
  # simple commandline parsing usecases.
  #

  class AutoCommandline < Commandline

=begin
    #
    instance_methods.each do |m|
      private m if m !~ /^(__|instance_|object_|send$|class$|inspect$|respond_to\?$)/
    end

    class << self

      #def inherited(subclass)
#p usage.to_s
#p subclass.usage.to_s
#        subclass.usage = self.usage.clone #deep copy?
#p subclass.usage.to_s
#      end

      # Command usage.
      def usage
        @usage ||= (
          if ancestors[1] < Commandline
            ancestors[1].usage.dup
          else
            Usage.new
          end
        )
      end

      def usage=(u)
        raise ArgumentError unless u <= Usage
        @usage = u
      end

      #
      def subcommand(name, help=nil, &block)
        usage.subcommand(name, help, &block)
      end
      alias_method :command, :subcommand
      alias_method :cmd, :subcommand

      #
      def option(name, *aliases, &block)
        usage.option(name, *aliases, &block)
      end
      alias_method :switch, :option

      #
      def opt(label, help, &block)
        usage.opt(label, help, &block)
      end
      alias_method :swt, :opt

      #
      def argument(*n_type, &block)
        usage.argument(*n_type, &block)
      end

      #
      def help(string=nil)
        usage.help(string)
      end

      #
      #def arg(label, help, &block)
      #  usage.arg(label, help, &block)
      #end

    end

    # New Command.
    def initialize(argv=nil, opts={}, &block)
      argv_set(argv || ARGV)
      #if opts[:usage]
      #  @usage = opts[:usage]
      #else
      #  #@usage = load_cache
      #end
      if self.class == Commandline
        @usage = Usage.new
      else
        @usage = self.class.usage #|| Usage.new
      end
      @usage.instance_eval(&block) if block
    end

    #
    def argv_set(args)
      # convert to array if string
      if ::String===args
        args = Shellwords.shellwords(args)
      end
      # remove anything subsequent to '--'
      if index = args.index('--')
        args = args[0...index]
      end
      @argv = args
    end

    #
    def cli
      #parse unless @cli
      @cli
    end

    #
    #def usage(name=nil, &block)
    #  @usage ||= Usage.new(name)
    #  @usage.instance_eval(&block) if block
    #  @usage
    #end

    def usage
      @usage
    end

    #
    def to_s
      usage.to_s
    end

    #
    def help_text
      usage.help_text
    end

    alias_method :help, :help_text

    #
    def parse(args=nil)
      argv_set(args) if args
      @cli = parser.parse(@argv)
    end

    #
    def parser
      @parser ||= Usage::Parser.new(usage) #, @argv)
    end

    #
    def [](i)
      @cli[i]
    end

    #
    def command    ; cli.command    ; end

    #
    def commands   ; cli.commands   ; end

    #
    def arguments  ; cli.arguments  ; end

    #
    def switches   ; cli.options    ; end

    #
    alias_method :options, :switches

    # Parameters
    #
    def parameters ; cli.parameters ; end

    #
    def to_a
      cli.to_a
    end

    # Commandline fully valid?
    #
    def valid?
      @cli.valid?
    end

    # TODO: adding '-' is best idea?
    #
    def completion(argv=nil)
      argv_set(argv) if argv
      @argv << "\t"
      parse
      @argv.pop
      parser.errors[0][1].completion.collect{ |s| s.to_s }
      #@argv.pop if @argv.last == '?'
      #load_cache
      #parse
    end

    #
    #def load_cache
    #  if usage = Usage.load_cache
    #    @usage = usage
    #  end
    #end
=end

    # Method missing provide passive usage and parsing.
    #
    # TODO: This reparses the commandline after every query.
    #       Really only need to parse if usage has change.
    #
    def method_missing(s, *a)
      begin
        s = s.to_s
        case s
        when /[=]$/
          n = s.chomp('=')
          usage.option(n).type(*a)
          parse(@argv)
          res = @cli.options[n.to_sym]
        #when /[!]$/
        #  n = s.chomp('!')
        #  cmd = usage.command(n, *a) #||usage.commands[n.to_sym] ||  
        #  res = parse(@argv)
        when /[?]$/
          n = s.chomp('?')
          u = usage.option(n, *a)
          parse(@argv)
          res = @cli.options[u.key]
        else
          n = s.chomp('!')
          cmd = usage.command(n, *a) #||usage.commands[n.to_sym] ||  
          res = parse(@argv)
          #usage.option(s, *a)
          #parse
          #res = @cli.options[s.to_sym]
        end
      rescue Usage::ParseError => e
        res = nil
      end
      return res
    end

  end # class Commandline

end # module Clio



=begin demo 1

  cli = Clio::Commandline.new

  cli.usage do
    command(:document) do
      help('generate documentation')
      option(:output, :o) do
        type('FILE')
        help('output directory')
      end
    end
    option(:verbose, :V) do
      help('verbose output')
    end
    option(:quiet, :q) do
      help('run silently')
      xor(:verbose)
    end
  end

  #p cli
  puts
  puts cli.help_text

=end

=begin demo 2

  cli = Clio::Commandline.new('--verbose')

  cli.usage do
    cmd(:document, 'generate documentation') do
      opt('--output=FILE -o', 'output directory')
    end
    opt('--verbose -V', 'verbose output')
    opt('--quiet -q', 'run silently')
  end

=end

=begin demo 3

#  cli.usage %{
#    document                generate documentation
#        -o --output=FILE    output directory
#    -V --verbose            verbose output
#    -q --quiet              run silently
#  }

  #p cline.verbose?(:V)
  #p cline.force?(:f)
  #p cline.document.output='FILE'

  p cli
  puts
  puts cli.help_text

=end

#cli[['--verbose', '-V'],['--quiet', '-q']] \
#   ['--force'] \
#   ['document']['--output=FILE', '-o']

