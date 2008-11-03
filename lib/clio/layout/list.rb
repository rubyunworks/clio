require 'clio/layout'

module Clio

  class Layout

    # List of items.
    class List < Layout

      attr :items

      def initialize(*items)
        options = Hash===items.last ? items.pop : {}

        @items  = items
        @mark   = options[:mark]
      end

      def to_s
        s = [""]
        n = (items.size / 10).to_i + 1
        items.each_with_index do |item, index|
          s << "%#{n}s. %s" % [index+1, item]
        end
        s << ""
        s.join("\n")
      end

    end

  end

end
