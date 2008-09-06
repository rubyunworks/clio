require 'clio/consoleutils'

module Clio

  # TODO: name LeftRight instead?
  class Split

    PAD   = ''
    FILL  = ' '
    RATIO = 0.8

    attr_accessor :left

    attr_accessor :right

    attr_accessor :fill

    attr_accessor :ratio

    attr_accessor :pad

    ###
    def initialize(left, right, options={})
      @left    = left
      @right   = right

      @fill    = FILL
      @ratio   = RATIO
      @pad     = PAD

      options.each do |k,v|
        send("#{k}=",v) if respond_to?("#{k}=")
      end
    end

    def print
      print_justified(@left, @right)
    end

    def ratio=(value)
      if value < 0
        @ratio = 1 + value
      else
        @ratio = value
      end
    end

    def fill=(letter)
      case letter
      when '', nil
        letter = ' '
      else
        letter = letter[0,1]
      end
      @fill = letter
    end

    def to_s
      print_justified(left, right)
    end

  private

    # Print a justified line with left and right entries.
    #
    # A fill option can be given to fill in any empty space
    # between the two. And a ratio option can be given which defaults
    # to 0.8 (eg. 80/20)
    #
    def print_justified(left, rite)
      left_size = left.size
      rite_size = rite.size

      left = left.to_s
      rite = rite.to_s

      width = screen_width

      l = (width * ratio).to_i
      r = width - l

      left = left[0,l]
      rite = rite[0,r]

      str = fill * width

      str[0,pad.size] = pad
      str[pad.size,left_size] = left
      str[-(pad.size+rite_size), rite_size] = rite
      str[-pad.size, pad.size] = pad

      Kernel.print(str)
    end

    ###
    def screen_width
      @screen_width ||= Terminal.screen_width
    end

  end

end


__END__

### demo ###

require 'clio/string2'

s1 = Clio.string("Left").color(:red)
s2 = Clio.string("Right").color(:green)

s = (s1 | s2)

s.print

