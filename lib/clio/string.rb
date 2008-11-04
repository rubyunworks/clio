require 'clio/ansicode'
require 'clio/layout/split'

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
        codes.each do |code|
          s.insert(index, ANSICode.send(code))
        end
      end
      s
    end

    def size ; text.size ; end

    ###
    def color!(ansicolor)
      marks[0] << ansicolor
      marks[size] << :clear
    end

    ###
    def color(ansicolor)
      m = marks.dup
      m[0] << ansicolor
      m[size] << :clear
      self.class.new(text, m)
    end

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
        other.marks.each{ |i, c| m[i] << c }
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

    # TODO: block support and \1, \2 support.
    def sub(pattern,replacement)
      if md = pattern.match(@text)
        delta  = replacement.size - md.size
        marks2 = shift_marks(md.end, delta)
        text2  = text.sub(pattern,replacement)
        self.class.new(text2, marks2)
      else
        self.class.new(text, marks)
      end
    end

    #
    def gsub
    end

  private

    def shift_marks(index, delta)
      new_marks = {}
      marks.each do |i, v|
        case i <=> index
        when 0, -1
          new_marks[i] = v
        when 1
          new_marks[i+delta] = v
        end
      end
      new_marks
    end

  end

end

