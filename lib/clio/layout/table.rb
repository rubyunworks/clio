require 'clio/layout'

module Clio

  class Layout

    # = Table
    #
    # Currently the table layout class is very
    # simplistic. Ultimately it will support
    # headers, footers, and a varity of border
    # options.
    class Table < Layout

      attr :rows

      def initialize(*rows_of_cells, &block)
        @rows = rows_of_cells
      end

      def row(*cells, &block)
        @rows << cells
        instance_eval(&block)
      end

      def cell(acell)
        (@rows.last ||= []) << acell
      end

      def to_s
        #screen_width
        rows.collect{ |cells|
          cells.join(' ')
        }.join("\n")
      end

      ###
      #class Row
      #end

    end

  end

end

