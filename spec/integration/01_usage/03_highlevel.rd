== Highlevel Notation

Require library.

  require 'clio/usage'

Build commandline specification.

  use = Clio::Usage.new %{
    --verbose -v          do it loudly

    document              generate documents
      --output=PATH -o    where to put it
      <*FILES>
  }

It should have a command named 'document'.

  use.options.to_s.should  == "-v --verbose"
  use.commands.to_s.should == "document [-o --output=PATH] <FILES...>"

Parse it.

  cmd = use.parse("document -v -o 'lib/do' README")

QED.

