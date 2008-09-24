module Clio

  class Commandline
    require 'clio/commandline/command'

    # = Usage
    #
    # Usage specifies the toplevel "Command".
    #
    class Usage < Command

      def initialize(name=nil, &block)
        super
      end

    end #class Usage

  end #class Commandline

end #module Clio
