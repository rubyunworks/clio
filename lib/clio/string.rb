require 'clio/ansicode'
require 'clio/layout/split'
require 'clio/facets/string'

module Clio

  def self.string(str)
    String.new(str)
  end

  # Clio Strings stores a regular string (@text) and
  # a Hash mapping character index to ansicodes (@marks).
  # For example is we has the string:
  #
  #   "Big Apple"
  #
  # And applied the color red to it, the marks hash would be:
  #
  #   { 0=>[:red] , 9=>[:clear] }
  #
  class String

    attr :text
    attr :marks

    def initialize(text=nil, marks=nil)
      @text  = text  || ''
      @marks = marks || Hash.new{ |h,k| h[k]=[] }
    end

    def to_s
      s = text.dup
      m = marks.sort{ |a,b| b[0] <=> a[0] }
      m.each do |index, codes|
        codes.reverse_each do |code|
          s.insert(index, ANSICode.__send__(code))
        end
      end
      s
    end

    def size ; text.size ; end

    ###
    def upcase  ; self.class.new(text.upcase, marks) ; end
    def upcase! ; text.upcase! ; end

    ###
    def downcase  ; self.class.new(text.upcase, marks) ; end
    def downcase! ; text.upcase! ; end

    ###
    def +(other)
      case other
      when String
        ntext  = text + other.text
        nmarks = marks.dup
        omarks = shift_marks(0, text.size, other.marks)
        omarks.each{ |i, c| nmarks[i].concat(c) }
      else
        ntext  = text + other.to_s
        nmarks = marks.dup
      end
      self.class.new(ntext, nmarks)
    end

    def |(other)
      Split.new(self, other)
    end

    def lr(other, options={})
      Split.new(self, other, options)
    end

    ### slice
    def slice(*args)
      if args.size == 2
        index, len = *args
        endex  = index+len
        new_text  = text[index, len]
        new_marks = {}
        marks.each do |i, v|
          new_marks[i] = v if i >= index && i < endex
        end
        self.class.new(new_text, new_marks)
      elsif args.size == 1
        rng = args.first
        case rng
        when Range
          index, endex = rng.begin, rng.end
          new_text  = text[rng]
          new_marks = {}
          marks.each do |i, v|
            new_marks[i] = v if i >= index && i < endex
          end
          self.class.new(new_text, new_marks)
        else
          self.class.new(text[rng,1], {rng=>marks[rng]})
        end
      else
        raise ArgumentError
      end
    end

    alias_method :[], :slice

    # This is more limited than the normal String method.
    # It does not yet support a block, and +replacement+
    # won't substitue for \1, \2, etc. 
    #
    # TODO: block support.
    def sub!(pattern,replacement)
      mark_changes = []
      text = @text.sub(pattern) do |s|
        index  = $~.begin(0)
        delta  = (replacement.size - s.size)
        mark_changes << [index, delta]
        replacement
      end
      marks = @marks
      mark_changes.each do |index, delta|
        marks = shift_marks(index, delta, marks)
      end
      @text  = text
      @marks = marks
      self
    end

    #
    def sub(pattern,replacement)
      dup.sub!(pattern, replacement)
    end

    #
    def gsub!(pattern,replacement)
      mark_changes = []
      text = @text.gsub(pattern) do |s|
        index  = $~.begin(0)
        delta  = (replacement.size - s.size)
        mark_changes << [index, delta]
        replacement
      end
      marks = @marks
      mark_changes.each do |index, delta|
        marks = shift_marks(index, delta, marks)
      end
      @text  = text
      @marks = marks
      self
    end

    #
    def gsub(pattern_replacement)
      dup.gsub(pattern, replacement)
    end

    ###
    def ansi(code)
      m = marks.dup
      m[0] << code
      m[size] << :clear
      self.class.new(text, m)
    end
    alias_method :color, :ansi

    ###
    def ansi!(code)
      marks[0] << ansicolor
      marks[size] << :clear
    end
    alias_method :color!, :ansi!

    def red      ; color(:red)      ; end
    def green    ; color(:green)    ; end
    def blue     ; color(:blue)     ; end
    def black    ; color(:black)    ; end
    def magenta  ; color(:magenta)  ; end
    def yellow   ; color(:yellow)   ; end
    def cyan     ; color(:cyan)     ; end

    def red!     ; color!(:red)     ; end
    def green!   ; color!(:green)   ; end
    def blue!    ; color!(:blue)    ; end
    def black!   ; color!(:black)   ; end
    def magenta! ; color!(:magenta) ; end
    def yellow!  ; color!(:yellow)  ; end
    def cyan!    ; color!(:cyan)    ; end

  private

    #
    def shift_marks(index, delta, marks=nil)
      new_marks = {}
      (marks || @marks).each do |i, v|
        case i <=> index
        when -1
          new_marks[i] = v
        when 0, 1
          new_marks[i+delta] = v
        end
      end
      new_marks
    end

    #
    def shift_marks!(index, delta)
     @marks.replace(shift_marks(index, delta))
    end

  end # class String

end # module Clio

