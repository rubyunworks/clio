# = Examples
#
# This is the example on the website.

require 'clio/usage'
require 'clio/string'

use = Clio::Usage.new

use['document', 'generate docs']['--output=PATH -o']
use['document']['<*files>']
use['show']['<*files>']
use['wack']['<*files>']
use['hump']['<*files>']

use['--verbose -v', 'say it loudly']
use['--help -h']

cli = use.parse('document -v -o doc/ README [A-Z]*')

cli.command   #=> "document"
cli.verbose?  #=> true

p cli.options
p cli.arguments
p cli.errors

puts '---'

#cli.document.options    #=> [:output => "doc/"]
#cli.document.arguments  #=> ["README", "[A-Z]*"]

cli = use.parse('document --help')

#puts use.command(cli.command).help

puts use.help.brief

puts '---'

if cli.help?
  puts Clio::String.new(use.help_text){ |s|
    s.gsub!(/^\w+\:/){ |w| w.bold.underline }
    s.gsub!(/[-]{1,2}\w+/){ |w| w.blue }
  }
end


