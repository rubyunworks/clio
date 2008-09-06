require 'clio/layout'

module Clio

  ###
  class Table < Layout

    attr :rows

    def initialize(*rows_of_cells, &block)
      @rows = rows_of_cells
    end

    def row(*cells, &block)
    end

    def to_s
      #screen_width
      rows.collect{ |cells|
        cells.join(' ')
      }.join("\n")
    end

    ###
    class Row
    end

  end

end

