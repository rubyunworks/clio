module Clio

  ### Draws a horizonal line.
  class Line < Layout

    attr :fill

    def initialize(fill='-')
      @fill = '-'
    end

    def to_s
      fill * screen_width
    end

  end

end

