module Clio

  class Commandline

    # = Commandline Argument
    #
    class Argument

      def initialize(parent, slot)
        @parent = parent
        @slot   = slot
      end

      def help(string=nil)
        @help.replace(string.to_s) if string
        @help
      end

      def to_s
        "#{slot}".upcase
      end

    end #class Argument

  end #class Commandline

end #module Clio

