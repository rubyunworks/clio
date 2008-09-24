require 'clio/ansicode'
require 'clio/layout/split'

module Clio

  def self.string(str)
    String.new(str)
  end

  # = Clio String class.
  #
  class String

    ESC_RE = /\e\[[0-9]*\w/

  private

    def initialize(*strings)
      @code = []
      @code.concat(strings.flatten)
    end

    attr :code

  public

    #
    def to_s
      s = ''
      code.each do |c|
        case c
        when String
          s << c.to_s
        when ::String
          s << c
        when ::Symbol
          s << ANSICode.send(c)
        end
      end
      s
    end

    #def to_str ; text ; end

    def []

    end

    #
    def +(append)
      nc = code + [append]
      self.class.new(*nc)
    end

    #
    def <<(append)
      code << append
    end

    def |(other)
      Split.new(self, other)
    end

    def lr(other, options={})
      Split(self, other, options)
    end

    #
    def size
      l = 0
      code.each do |c|
        case c when Symbol
        else
          l += c.size
        end
      end
      l
    end
    alias_method(:length, :size)

    # Get a string with color.
    def color(ansicolor)
      new_code = [ansicolor.to_sym, *code] + [:clear]
      self.class.new(*new_code)
    end

    # Give the string a color.
    def color!(ansicolor)
      code.unshift(ansicolor.to_sym)
      code.push(:clear)
    end

    def capitalize
      f = code.find{ |e| String===e }
      i = code.index(f)
      ncode = code.dup
      ncode[i] = f[0,1].upcase + f[1..-1]
      self.class.new(ncode)
    end

    def downcase
      self.class.new(code.map do |c|
        case c when String, ::String
          c.downcase
        else
          c
        end
      end)
    end

    #--
    # TODO: No doubt the delegation will need to be made more robust.
    #++

    INPLACE_DELEGATE_METHODS = /(\[\]=|replace|!$)/
    EXCLUDE_DELEGATE_METHODS = /(split|^to_)/

    # Delegate to underlying text/ansi.
    def method_missing(s, *a, &b)
      case s.to_s
      when EXCLUDE_DELEGATE_METHODS
        super
      when INPLACE_DELEGATE_METHODS
        apply!(s, *a, &b)
      else
        apply(s, *a, &b)
      end
    end

  private

    #
    def apply(s, *a, &b)
      nc = code.map do |c|
        case c when String, ::String
          c.send(s, *a, &b)
        else
          c
        end
      end
      self.class.new(nc)
    end

    #
    def apply!(s, *a, &b)
      @code = code.map do |c|
        case c when String, ::String
          c.send(s, *a, &b)
        else
          c
        end
      end
    end

  end

end


__END__

### test ###

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

end

