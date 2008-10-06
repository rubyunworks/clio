require 'shellwords'
#require 'facets/kernel/object_class'
require 'facets/array/indexable'

module Clio

  # = Commandline
  #
  # Clio Commandline is a very versitile command line parser.
  # A Commandline can be used either declaritively, defining usage
  # and help information upfront; or lazily, whereby information
  # about usage is built-up as the commandline actually gets usde in
  # one's program; or you can use a mixture of the two.
  #
  # Underlying all useage is a fluent interface for decalaring
  # a commandline's structure. Here is an example of using this
  # DSL directly.
  #
  #   cli = Clio::Commandline.new
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
  #   cli = Clio::Commandline.new
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
  # Clearly block notation is DRY and much easier to read, but the
  # fluent notation is important to have because it allows the
  # Commandline object to passed around and modified as needed.
  #
  # Commandline's usage DSL is a bit verbose. So Commandline
  # provides a shorthand notation for declaring usage to simplify
  # the process, which is esspecially useful when the usage
  # is static.
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
  #--
  # Commandline offers one additional alternative in the form of an
  # array structure:
  #
  #   cli.usage[
  #     [ 'document', '--output=FILE -o' ],
  #     [ '--verbose -V', '--quiet -q' ], '--force'
  #   ]
  #
  #    cli['document']['--output=FILE -o']
  #    cli['--verbose -V','--quiet -q']['--force']
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
  # The Commandline class allows you to declare as little or as
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
    require 'clio/commandline/usage'
    require 'clio/commandline/parse'

    #
    instance_methods.each do |m|
      private m if m !~ /^(__|instance_|object_|send$|class$|inspect$|respond_to\?$)/
    end

    #
    def initialize(argv=nil, opts={}, &block)
      @argv = if String === argv
        Shellwords.shellwords(argv)
      else
        argv || ARGV
      end
      @usage = opts[:usage] if opts[:usage]
      usage(&block) if block
    end

    #
    def parse
      parser.parse
    end

    #
    def usage(name=nil, &block)
      @usage ||= Main.new(name)
      @usage.instance_eval(&block) if block
      @usage
    end

    #
    def parser
      @parser ||= Parse.new(usage, @argv)
    end

    #
    def [](i)
      #parser.parse
      parser[i]
    end

    #
    def commands
      #parser.parse
      parser.commands
    end

    #
    def command
      #parser.parse
      parser.command
    end

    #
    def arguments
      #parser.parse
      parser.arguments
    end

    #
    def switches
      #parser.parse
      parser.options
    end

    alias_method :options, :switches

    # Parameters
    #
    #
    def parameters
      parser.parameters
    end

    #
    def to_a
      #parser.parse
      parser.to_a
    end

    #
    def to_s
      usage.to_s
    end

    #
    def to_s_help
      usage.to_s_help
    end

    # Method missing provide passive usage and parsing.
    #
    # TODO: This reparses the commandline after every usage
    #       change. Is there a way to do partial parsing instead?
    def method_missing(s, *a)
      begin
        s = s.to_s
        case s
        when /[=]$/
          n = s.chomp('=')
          usage.option(n).type(*a)
          #parser.parse
          res = parser.options[n.to_sym]
        when /[!]$/
          n = s.chomp('!')
          cmd = usage.commands[n.to_sym] || usage.command(n, *a)
          res = parser.parse
        when /[?]$/
          n = s.chomp('?')
          u = usage.option(n, *a)
          res = parser.options[u.key]
        else
          usage.option(s, *a)
          #parser.parse
          res = parser.options[s.to_sym]
        end
      rescue ParseError => e
        res = nil
      end
      return res
    end

    #def valid?
    #  usage.options.each do |o|
    #    parser.option!(o.name)
    #  end
    #
    #  if usage.commands.empty?
    #  else
    #    cmd = usage.command[parser[0].to_sym]
    #    return false unless cmd
    #    
    #  end
    #end

  end

end



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

