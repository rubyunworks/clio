require 'clio/layout'

module Clio

  class Layout

    class Stack < Layout

      def initialize(&block)
        instance_eval(&block)
      end

    end

  end

end
