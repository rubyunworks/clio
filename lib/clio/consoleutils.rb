module Clio

  # = ConsoleUtils
  #
  # ConsoleUtils provides methods that are
  # generally useful in the context of
  # creating console output.
  #
  module ConsoleUtils
    module_function

    DEFAULT_WIDTH = ENV['COLUMNS'] || 80


    # Convenient method to get simple console reply.
    #
    #   ask("Are you good?") do |answer| 
    #     raise AnswerRetry unless answer =~ /(yes|no|y|n)/i
    #     answer
    #   end
    #
    def ask(question, answers=nil, &validate)
      ans = nil
      until ans
        $stdout << "#{question} "
        $stdout << "[#{answers}] " if answers  # TODO: support this?
        $stdout.flush
        until inp = $stdin.gets ; sleep 1 ; end  # replace with better routine
        inp.strip!
        if validate
          begin
            ans = validate[inp] || inp
          rescue AnswerRetry => err
            puts err.message || "Invalid entry, please try again."
          rescue AnswerTerminate => err
            puts err.message || "Invalid entry."
            exit -1
          end
        else
          ans = inp
        end
      end
      ans
    end

    #
    class AnswerRetry < Exception
      def initialize(msg=nil)
        super(msg); @message = msg
      end
      def message ; @message ; end
    end

    #
    class AnswerTerminate < Exception
      def initialize(msg=nil)
        super(msg); @message = msg
      end
      def message ; @message ; end
    end

    # Convenience method for puts. Use this instead of
    # puts when the output should be supressed if the
    # global $QUIET option is set.

    #def say(statement)
    #  puts statement #unless quiet? $QUIET
    #end

    # Ask for a password. (FIXME: only for unix so far)

    def password(msg=nil)
      msg ||= "Enter Password: "
      inp = ''

      $stdout << msg

      begin
        system "stty -echo"
        inp = gets.chomp
      ensure
        system "stty echo"
      end

      return inp
    end

    # Console screen width.
    #
    def screen_width(out=STDERR)
      @width ||= (
        w = nil
        begin
          tiocgwinsz = 0x5413
          data = [0, 0, 0, 0].pack("SSSS")
          if out.ioctl(tiocgwinsz, data) >= 0 then
            rows, cols, xpixels, ypixels = data.unpack("SSSS")
            w = cols if cols >= 0
          end
        rescue Exception
        end
        unless w
          begin
            require 'curses'
            Curses.init_screen
            w = Curses.cols
            Curses.close_screen
          rescue
          end
        end
        w || DEFAULT_WITDH
      )
    end

    # Print a justified line with left and right entries.
    #
    # A fill option can be given to fill in any empty space
    # between the two. And a ratio option can be given which defaults
    # to 0.8 (eg. 80/20)
    #
    def print_justified(left, right, options={})
      fill  = options[:fill] || '.'
      fill  = ' ' if fill == ''
      fill  = fill[0,1]

      ratio = options[:ratio] || 0.8
      ratio = 1 + ratio if ratio < 0

      width = (@screen_width ||= screen_width) - 1

      #l = (width * ratio).to_i
      r = (width * (1 - ratio)).to_i
      l = width - r

      left  = left[0,l]
      right = right[0,r]

      str = fill * width
      str[0,left.size] = left
      str[width-right.size,right.size] = right

      print str
    end

  end

end

# TODO: do this?
class Object
  include Clio::ConsoleUtils
end


