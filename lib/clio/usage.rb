require 'clio/usage/subcommand'
require 'clio/usage/parser'

module Clio

  # = Usage
  #
  # Uasge provides a verstile but easy to use system of describing
  # a commandline interface.
  #
  # == Underlying Fluent and Block Notation
  #
  # Underlying all usage is a fluent interface for decalaring
  # a commandline's structure. Here is an example of using
  # this DSL, albeit rather brutely.
  #
  #   usage = Clio::Usage.new
  #   usage.command(:document).help('generate documentation')
  #   usage.command(:document).option(:output, :o).type('FILE')
  #   usage.command(:document).option(:output).help('output directory')
  #   usage.option(:verbose, :V).help('verbose output')
  #   usage.option(:quiet, :q).help('run silently').xor(:V)
  #
  # The example defines a subcommand 'document' that can take an
  # 'output' option, and two mutually excluive universal options,
  # 'verbose' and 'quiet', with respective one-letter aliases.
  #
  # As you might expect the fluent notation can be broken down into
  # block notation which is easier to read.
  #
  #   usage = Usage.new
  #   usage do
  #     option(:verbose, :v) do
  #       help('verbose output')
  #     end
  #     option(:quiet, :q) do
  #       help('run silently')
  #       xor(:V)
  #     end
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
  #   end
  #
  # Clearly block notation is DRY and more elegant the the previous fluent
  # version, but fluent notation is important because it allows the usage
  # object to be easily passed around and augmented as needed.
  #
  #--
  # == Abbriviated Notation
  #
  # While comprehensble, the core Usage DSL can be a somewhat verbose.
  # So abbriviated forms of these methods are provided. These methods
  # go one step further as well, and allow for some additional arguments.
  #
  #   cli.usage do
  #     opt('verbose -v', 'verbose output') |
  #     opt('quiet -q'  , 'run silently')
  #     cmd('document', 'generate documentation') do
  #       opt('output=FILE -o', 'output directory')
  #       arg('FILE*')
  #     end
  #   end
  #
  # Notice the use of '|'. This allows us to define mutual exclusion
  # without resorting to #xor as was done in the first example.
  #++
  #
  #--
  #
  # = Method Notation
  #
  # This notation is very elegant, but slightly more limited in scope.
  # For instance, subcommands that use non-letter characters, such as ':',
  # can not be described with this notation.
  #
  #   usage.document('<file*>', '--output=FILE -o')
  #   usage('--verbose -V','--quiet -q')
  #
  #   usage.help(
  #     'document'     , 'generate documentation',
  #     'validate'     , 'run tests or specifications',
  #     '--verbose'    , 'verbose output',
  #     '--quiet'      , 'run siltently'
  #   )
  #
  #   usage.document.help(
  #     '--output', 'output directory'
  #     'file*',    'files to document'
  #   )
  #
  #++
  #
  # This notation is slightly more limited in scope... so...
  #
  #   usage.command(:document, '--output=FILE -o', '<file*>')
  #
  # == Bracket Shorthand Notation
  #
  # The core notation can be somewhat verbose. As a further convenience
  # commandline usage can be defined with a brief <i>bracket shorthand</i>.
  # This is especailly useful when the usage is simple and statically defined.
  #
  #   usage['document']['--output=FILE -o']['FILE*']
  #
  # Using a little creativity to improve readabilty we can convert the
  # whole example from above using this notation.
  #
  #   usage['--verbose -V',        'verbose output'       ] \
  #        ['--quiet -q',          'run silently'         ] \
  #        ['document',            'generate documention' ] \
  #        [  '--output=FILE -o',  'output directory'     ] \
  #        [  'FILE*',             'files to document'    ]
  #
  # Alternately the help information can be left out and defined in
  # a separate set of usage calls.
  #
  #   usage['--verbose -V']['--quiet -q'] \
  #        ['document']['--output=FILE -o']['FILE*']
  #
  #   usage.help(
  #     'document'  , 'generate documentation',
  #     'validate'  , 'run tests or specifications',
  #     '--verbose' , 'verbose output',
  #     '--quiet'   , 'run siltently'
  #   )
  #
  #   usage['document'].help(
  #     '--output', 'output directory'
  #     'FILE',     'files to docment'
  #   )
  #
  # A little more verbose, but also a bit more intuitive.
  #
  #--
  #
  # == "Alien" Notation
  #
  # As a side note, it is easy enough to alias #[] to #_, so alternatively
  # one code create a variant shorthand written as:
  #
  #   usage do
  #     _ '--verbose -V',         'verbose output'
  #     _ '--quiet -q',           'run silently'
  #     _ 'document',             'generate documentation' do
  #        _ '--output=FILE -o',  'output directory'
  #        _ 'FILE*',             'files to document'
  #     end
  #   end
  #
  # To demonsrtate it's equvalence to bracket shorthand, it can be chained as well.
  #
  #   usage._('document')._('--output=FILE -o')._('FILE*')
  #
  # This notation is not supported by default, but if it is more your style
  # it is easy enough to implement by extending Clio::Usage::Command like this:
  #
  #   class Clio::Usage::Command
  #     alias_method :_, :[]
  #   end
  #
  #++
  #
  # == Combining Notations
  #
  # Since the various notations all translate to same underlying
  # structures, they can be mixed and matched as suites ones taste.
  # For example we could mix Method Notation and Bracket Notation.
  #
  #   usage.command(:document)['--output=FILE -o']['file*']
  #   usage['--verbose -V']['--quiet -q']
  #
  # The important thing to keep in mind when doing this is what is
  # returned by each type of usage call.
  #
  class Usage

    BLANK        = /^\s*$/
    COMMAND      = /^\w/   # NOT GOOD ENOUGH

    #LONG_OPTION  = /^--/
    #SHORT_OPTION = /^-\S/

    instance_methods.each{ |m| private m unless m =~ /^__/ }

    attr :main

    #
    def initialize(usage=nil, &block)
      raise ArgumentError if usage && block
      case usage
      when nil
        @main = Subcommand.new(name, &block)
      when Subcommand
        @main = usage
      else
        @main = Usage.parse_usage(name, usage)
      end
    end

    #
    def method_missing(s, *a, &b)
      @main.send(s, *a, &b)
    end

    #
    #def copyright(text=nil)
    #  @copyright = text
    #end

    #
    def parse(argv)
      Parser.new(@main).parse(argv)  #, argv).parse
    end

    # Cache usage into a per-user cache file for reuse.
    # This can be used to greatly speed up tab completion.
    #
    def cache
      File.open(cache_file, 'w'){ |f| f << to_yaml }
    end

    # TODO
    def name
      File.basename($0)
    end

    private #-----------------------------------------------------------------

      # TODO: Use XDG

      def cache_file
        File.join(File.expand_path('~'), '.cache', 'clio', "#{name}.yaml")
      end

      def self.cache_file
        File.join(File.expand_path('~'), '.cache', 'clio', "#{name}.yaml")
      end

      def self.load_cache
        if File.file?(cache_file)
          YAML.load(File.new(cache_file))
        end
      end


    #
    def self.parse_usage(name, text)
      cmd = Subcommand.new(name)

      txt = text.sub(/\A\s*?\n/, '')

      use = command
      tab = indent_length(txt)
      use_stack = []
      tab_stack = []

      txt.each_line do |line|
        next if BLANK =~ line

        # at least 4 spaces divide help from element
        opt, help = *line.strip.split('    ')
        opt, help = opt.to_s.strip, help.to_s.strip

        i = indent_length(line)
#p '#1', i, tab, use
        if i < tab
          until i >= tab
            use = use_stack.pop
            tab = tab_stack.pop
          end
        end
#p '#2', use
        u = use[opt, help]
#p '#3', u
        if Subcommand === u
          use = u
          tab = i
          use_stack << u
          tab_stack << i
        end

        #if ARGS =~ opt
        #  use = use_stack.pop
        #  tab_stack.pop
        #end
      end

      return cmd
    end

    #
    def self.indent_length(line)
      /^(\s+)\S/.match(line)[1].length
    end

  end#module Usage

end#module Clio

