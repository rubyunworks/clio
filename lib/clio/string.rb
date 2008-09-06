require 'clio/ansicode'
require 'clio/layout/split'

module Clio

  def self.string(str)
    String.new(str)
  end

  ###
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
      Split(self, other, options)
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

  end

end


__END__


require 'quarry/spec'

Quarry.spec "Clio::String" do

  s1 = "Hi how are you."
  s2 = "Fine thanks."

  c1 = Clio.string("Hi how are you.")
  c2 = Clio.string("Fine thanks.")

  verify "color" do
    r = c1.color(:red)
    e = Clio::ANSICode.red(s1)
    e.assert == r.to_s
  end

  verify "non-in-place delegation" do
    r = c1.upcase
    e = s1.upcase
    e.assert == r.to_s
  end

  verify "string addition" do
    r = c1 + c2
    e = s1 + s2
    e.assert == r.to_s
  end

  verify "string single index" do
    r = c1[0]
    e = s1[0,1]
    e.assert == r.to_s
  end

  verify "string size index" do
    r = c1[0,3]
    e = s1[0,3]
    e.assert == r.to_s
  end

  verify "string range index" do
    r = c1[0..3]
    e = s1[0..3]
    e.assert == r.to_s
  end

end

