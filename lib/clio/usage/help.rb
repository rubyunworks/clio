module Clio

  module Usage

    class Help

      #
      def initialize(usage)
        @usage = usage
      end

      #
      def text=(txt)
        @user_text = txt
      end

      #
      def text(string=nil)
        self.text = string if string
        return @user_text if @user_text
        s = []
        s << usage
        s << description
        s << details
        s << copyright
        s.join("\n\n")
      end

    end

  end #module Usage

end #module Clio

