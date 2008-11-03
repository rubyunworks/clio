require 'facets/kernel/deep_copy'
require 'clio/usage'
#require 'shellwords'
#require 'facets/kernel/object_class'
#require 'facets/array/indexable'

module Clio

  # = Commandline
  #
  # Clio's Commandline class is a very versitile command line parser.
  # A Command can be used either declaritively, defining usage
  # and help information upfront; or lazily, whereby information
  # about usage is built-up as the commandline actually gets usde in
  # one's program; or you can use a mixture of the two.
  #
  #
  # This notation is very elegant, but slightly more limited in scope.
  # For instance, subcommands that use non-letter characters, such as ':',
  # can not be described with this notation.
  #
  #   cli.usage.document('*files', '--output=FILE -o')
  #   cli.usage('--verbose -V','--quiet -q')
  #
  #   cli.usage.help(
  #     'document'     , 'generate documentation',
  #     'validate'     , 'run tests or specifications',
  #     '--verbose'    , 'verbose output',
  #     '--quiet'      , 'run siltently'
  #   )
  #
  #   cli.usage.document.help(
  #     '--output', 'output directory'
  #     'file*',    'files to document'
  #   )
  #
  # This notation is slightly more limited in scope... so...
  #
  #   cli.usage.command(:document, '--output=FILE -o', 'files*')
  #
  #

  # Underlying all usage is a fluent interface for decalaring
  # a commandline's structure. Here is an example of using this
  # DSL directly.
  #
  #   cli = Clio::Commandline.new
  #   cli.usage.command(:document).help('generate documentation')
  #   cli.usage.command(:document).option(:output, :o).type('FILE')
  #   cli.usage.command(:document).option(:output).help('output directory')
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
  #       argument('files') do
  #         multiple
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
  # Clearly block notation is DRY and easier to read, but fluent
  # notation is important to have because it allows the Commandline
  # object to be passed around as an argument and modified easily.
  #
  # == Abbriviated Notation
  #
  # While comprehensble, the core Usage DSL can be a somewhat verbose.
  # So abbriviated forms of these methods are provided. These methods
  # go one step further as well, and allow for some additional arguments.
  #
  #   cli.usage do
  #     cmd('document', 'generate documentation') do
  #       opt('output=FILE -o', 'output directory')
  #       arg('FILE*')
  #     end
  #     opt('verbose -v', 'verbose output') |
  #     opt('quiet -q'  , 'run silently')
  #   end
  #
  # Notice the use of '|'. This allows us to define mutual exclusion
  # without resorting to #xor as was done in the first example.
  #
  # == Shorthand Notation
  #
  # As a further convenience commandline usage can be defined with a
  # shorthand notation. This is especailly useful when the usage is
  # statically definable.
  #
  #   cli.usage do
  #     _ 'document',             'generate documentation' do
  #        _ '--output=FILE -o',  'output directory'
  #        _ 'FILE*',             'files to document'
  #     end
  #     _ '--verbose -V',         'verbose output'
  #     _ '--quiet -q',           'run silently'
  #   end
  #
  # The shorthand notation is chainable.
  #
  #   cli.usage._('document')._('--output=FILE -o')._('FILE*')
  #
  # Interstingly, it was easy enough to alias #[] to #_ so, alternatively
  # shorthand can be written as:
  #
  #   cli.usage['document']['--output=FILE -o']['FILE*']
  #
  # Exanding the whole example from above we get:
  #
  #   cli.usage['document',            'generate documention' ] \
  #            [  '--output=FILE -o',  'output directory'     ] \
  #            [  'FILE*',             'files to document'    ]
  #
  #   cli.usage['--verbose -V', 'verbose output']['--quiet -q', 'run silently']
  #
  #--
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
  # == Combining Notations
  #
  # Since the various notations all translate to same underlying data
  # structures, they can be mixed and matched as suites ones taste.
  # For example we could mix Method Notation and Bracket Notation.
  #
  #   cli.usage.document['--output=FILE -o']['file*']
  #   cli.usage['--verbose -V']['--quiet -q']
  #
  # The important thing to keep in mind when doing this is what is
  # returned by each usage call.
  #
  # == Commandline Parsing
  #
  # With usage in place, call the +parse+ method to process the
  # actually commandline.
  #
  #   cli.parse
  #
  # If no command arguments are passed to +parse+, ARGV is used.
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
  #++
  #
  # == Usage Cache
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

  class Commandline

    #
    instance_methods.each do |m|
      private m if m !~ /^(__|instance_|object_|send$|class$|inspect$|respond_to\?$)/
    end

    class << self

      def self.inherited(subclass)
        subclass.usage = usage.deep_copy
      end

      # Command usage.
      def usage
        @usage ||= Usage.new
      end

      def usage=(u)
        raise ArgumentError unless u <= Usage
        @usage = u
      end

      #    if ancestors[1] < Command
      #      @usage = ancestors[0].usage.deep_copy
      #    else
      #      @usage = Usage.new
      #    end

      #
      def command(*names, &block)
        usage.command(*names, &block)
      end

      #
      def option(name, *aliases, &block)
        usage.option(name, *aliases, &block)
      end

      #
      def switch(name, *aliases, &block)
        usage.switch(name, *aliases, &block)
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
      @usage = self.class.usage.deep_copy
      @usage.instance_eval(&block) if block
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
      @usage
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

    # Method missing provide passive usage and parsing.
    #
    # TODO: This reparses the commandline after every query.
    #       Need only parse if usage has change.
    def method_missing(s, *a)
      begin
        s = s.to_s
        case s
        when /[=]$/
          n = s.chomp('=')
          usage.option(n).type(*a)
          parse
          res = @cli.options[n.to_sym]
        when /[!]$/
          n = s.chomp('!')
          cmd = usage.commands[n.to_sym] || usage.command(n, *a)
          res = parse
        when /[?]$/
          n = s.chomp('?')
          u = usage.option(n, *a)
          parse
          res = @cli.options[u.key]
        else
          usage.option(s, *a)
          parse
          res = @cli.options[s.to_sym]
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
