# = Examples
#
# This is the example on the website.

  require 'clio/commandline'
  require 'clio/string'

  cli = Clio::Commandline.new

  cli.usage.document('--output=PATH -o', '*FILES')
  cli.usage.verbose?('-v')

  cli.usage.help!(
    'document', 'generate docs',
    '--verbose',  'do it loudly'
  )

  cli.parse('document -v -o doc/ README [A-Z]*')

  cli.command   #=> "document"
  cli.verbose?  #=> true

  cli.document!.options    #=> [:output => "doc/"]
  cli.document!.arguments  #=> ["README", "[A-Z]*"]

  cli.parse('--help')

  if cli.help?
    puts Clio::String.new(cli.help){ |s|
      s.gsub!(/^\w+\:/){ |w| w.bold.underline }
      s.gsub!(/[-]{1,2}\w+/){ |w| w.blue }
    }
  end

