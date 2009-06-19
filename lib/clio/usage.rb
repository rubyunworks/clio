require 'clio/usage/command'
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
  # a seprate set of usage calls.
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
  # A little more verbose, but a bit more intutive.
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
  module Usage

    def self.new(name=nil, &block)
      Command.new(name, &block)
    end

  end#module Usage

end#module Clio

