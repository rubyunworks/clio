= Examples

This is the example on the website.

  require 'clio/commandline'

  cli = Clio::Commandline.new

  cli.usage.document('--output=PATH -o', '*FILES')
  cli.usage.verbose?('-v')

  cli.usage.help!(
    'document', 'generate docs',
    '--verbose',  'do it loudly'
  )

  cli.parse('document -v -o doc/ README [A-Z]*')

  if cli.help?
    puts Clio::String.new(cli.help) do |s|
      s.gsub(/\A.*?$/){ |w| w.bold.underline }
      s.gsub(/^\w+\:/){ |w| w.bold }
      s.gsub(/-\w+/){ |w| w.blue }
    end
    exit
  end

  cli.command   #=> "document"
  cli.verbose?  #=> true

  p cli.document!

  cli.document!.options    #=> [:output => "doc/"]
  cli.document!.arguments  #=> ["README", "[A-Z]*"]

