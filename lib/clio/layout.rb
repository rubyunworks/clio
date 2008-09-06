require 'clio/consoleutils'

module Clio

  class Layout

    def screen_width
      @screen_width ||= Terminal.screen_width
    end

  end

end

