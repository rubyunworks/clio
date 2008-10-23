require 'facets/kernel/deep_copy'
require 'clio/usage'
#require 'shellwords'
#require 'facets/kernel/object_class'
#require 'facets/array/indexable'

module Clio

  # = Command
  #
  # Clio's Command class is a very versitile command line parser.
  # A Command can be used either declaritively, defining usage
  # and help information upfront; or lazily, whereby information
  # about usage is built-up as the commandline actually gets usde in
  # one's program; or you can use a mixture of the two.
  #
  # Underlying all useage is a fluent interface for decalaring
  # a commandline's structure. Here is an example of using this
  # DSL directly.
  #
  #   cli = Clio::Command.new
  #   cli.usage.command(:document).help('generate documentation')
  #   cli.usage.command(:document).opion(:output, :o).type('FILE')
  #   cli.usage.cmd(:document).option(:output).help('output directory')
  #   cli.usage.option(:verbose, :V).help('verbose output')
  #   cli.usage.option(:quiet, :q).help('run silently').xor(:V)
  #
  # The example defines a subcommand 'document' that can take an
  # 'output' option, and two mutually excluive universal options,
  # 'verbose' and 'quiet', with respective one-letter aliases.
  #
  # As you might expect the fluent notation can be broken down into
  # block notation.
  #
  #   cli = Clio::Command.new
  #   cli.usage do
  #     command(:document) do
  #       help('generate documentation')
  #       option(:output, :o) do
  #         type('FILE')
  #         help('output directory')
  #       end
  #     end
  #     option(:verbose, :V) do
  #       help('verbose output')
  #     end
  #     option(:quiet, :q) do
  #       help('run silently')
  #       xor(:V)
  #     end
  #   end
  #
  # Clearly block notation is DRY and easier to read, but the
  # fluent notation is important to have because it allows the
  # Command object to easily passed and modified as needed.
  #
  # Command uses the Usage DSL, the core methods or which can be
  # a bit verbose. So it also provides shorthand notation to
  # simplify# the process, which is esspecially useful when the
  # usage is static.
  #
  #   cli.usage do
  #     cmd('document', 'generate documentation') do
  #       opt('--output=FILE -o', 'output directory')
  #     end
  #     opt('--verbose -V', 'verbose output') | 
  #     opt('--quiet -q'  , 'run silently')
  #   end
  #
  # Notice the use of '|'. This allows us to define mutual exclusion
  # without resorting to #xor as was done in the first example.
  #
  # With usage in place, call the +parse+ method to process the 
  # actually commandline.
  #
  #   cli.parse
  #
  # If no command arguments are passed to +parse+, ARGV is used.
  #
  #--
  # Command offers one additional alternative in the form of an
  # array structure:
  #
  #   cli.usage[
  #     [ 'document', '--output=FILE -o' ],
  #     [ '--verbose -V', '--quiet -q' ], '--force'
  #   ]
  #
  #   cli['document']['--output=FILE -o']
  #   cli['--verbose -V','--quiet -q']['--force']
  #
  # As you can see this is very concise, but it does not allow for
  # help information. So in this case help information has to be 
  # specified separately.
  #
  #   cli.usage.help[
  #     ['document'  , 'generate documentation'],
  #     ['validate'  , 'run tests or specifications'],
  #     ['--verbose' , 'verbose output'], 
  #     ['--quiet'   , 'run siltently' ]
  #   ]
  #
  #   cli.usage.cmd('document').help[
  #     ['--output', 'output directory']
  #   ]
  #++
  #
  #--
  # The Command class allows you to declare as little or as
  # much of the commandline interface upfront as is suitable to
  # your application. When using the commandline object, if not
  # already defined, options will be lazily created. For example:
  #
  #   cli = Clio::Commandline.new('--force')
  #   cli.force?  #=> true
  #
  # Commandline sees that you expect a '--force' flag to be an
  # acceptable option. So it will call cli.usage.option('force')
  # behind the scenes before trying to determine the actual value
  # per the content of the command line. You can add aliases as
  # parameters to this call as well.
  #
  #   cli = Clio::Commandline.new('-f')
  #   cli.force?(:f)  #=> true
  #
  # Once set, you do not need to specify the alias again:
  #
  #   cli.force?      #=> true
  #
  # With the exception of help information, this means you can
  # generally just use a commandline as needed without having
  # to declare anything upfront.
  #
  #++
  #
  # Lastly, Commandline  provides a simple means to cache usage
  # information to a configuration file, which then can be used
  # again the next time the same command is used. This allows
  # Commandline to provide high-performane tab completion.
  #
  # == Coming Soon
  #
  # In the future Commandline will be able to generate Manpage
  # templates.
  #
  #--
  # TODO: Allow option setter methods (?)
  # TODO: Allow a hash as argument to initialize (?)
  #++

  class Command

    class << self

      # Command usage.
      def usage
        @usage ||= (
          if ancestors[1] < Command
            @usage = ancestors[1].usage.deep_copy
          else
            @usage = Usage.new
          end
        )
      end

      #
      def command(*names, &block)
        usage.command(*names, &block)
      end

      #
      def option(name, *aliases, &block)
        usage.option(name, *aliases, &block)
      end

      #
      def argument(name, &block)
        usage.argument(name, &block)
      end

      #
      def help(string=nil)
        usage.help(string)
      end

      #
      def cmd(label, help, &block)
        usage.cmd(label, help, &block)
      end

      #
      def opt(label, help, &block)
        usage.opt(label, help, &block)
      end

      #
      def swt(label, help, &block)
        usage.swt(label, help, &block)
      end

      #
      def arg(label, help, &block)
        usage.arg(label, help, &block)
      end

    end

    # New Command.
    def initialize(argv=nil, opts={}, &block)
      argv_set(argv || ARGV)
      #if opts[:usage]
      #  @usage = opts[:usage]
      #else
      #  #@usage = load_cache
      #end
      (class << self; self; end).usage(&block) if block
    end

    #
    def argv_set(argv)
      # reset parser
      @parser = nil
      # convert to array if string
      if String===argv
        argv = Shellwords.shellwords(argv)
      end
      # remove anything subsequent to '--'
      if index = argv.index('--')
        argv = argv[0...index]
      end
      @argv = argv
    end

    #
    #def usage(name=nil, &block)
    #  @usage ||= Usage.new(name)
    #  @usage.instance_eval(&block) if block
    #  @usage
    #end

    def usage
      (class << self; self; end).usage
    end

    #
    def to_s
      usage.to_s
    end

    #
    def to_s_help
      usage.to_s_help
    end

    #
    def parse(argv=nil)
      argv_set(argv) if argv
      @cli = parser.parse
    end

    #
    def parser
      @parser ||= Usage::Parser.new(usage, @argv)
    end

    #
    def [](i)
      @cli[i]
    end

    #
    def command    ; @cli.command    ; end

    #
    def commands   ; @cli.commands   ; end

    #
    def arguments  ; @cli.arguments  ; end

    #
    def switches   ; @cli.options    ; end

    #
    alias_method :options, :switches

    # Parameters
    #
    def parameters ; @cli.parameters ; end

    #
    def to_a
      @cli.to_a
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
      @argv << '-'
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

  end # class Command

end # module Clio


=begin
    #
    def initialize(argv=nil, &block)
      @cli = Commandline.new(argv, :usage=>self.class.usage, &block)
    end

    def parse     ; @cli.parse     ; end

    #
    def usage     ; @cli.usage     ; end

    #
    def command   ; @cli.command   ; end

    #
    def commands  ; @cli.commands  ; end

    #
    def options   ; @cli.options   ; end

    #
    def arguments ; @cli.arguments ; end

    #
    def [](i)     ; @cli[i]        ; end

    #
    def method_missing(s, *a, &b)
      @cli.send(s, *a, &b)
    end
=end



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
  puts cli.to_s_help

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
  puts cli.to_s_help

=end

#cli[['--verbose', '-V'],['--quiet', '-q']] \
#   ['--force'] \
#   ['document']['--output=FILE', '-o']

