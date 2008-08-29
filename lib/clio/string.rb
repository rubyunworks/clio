#require 'facets/rope'
require 'clio/ansicode'
require 'facets/string/mask'

module Clio

  # = Clio String class.
  #
  class String

    ESC_RE = /\e\[[0-9]*\w/

  private

    def initialize(text, ansi=nil)
      @text = text.to_s
      @ansi = ansi || text.to_s
    end

  public

    attr :text

    attr :ansi

    #
    def to_s   ; ansi ; end

    #def to_str ; text ; end

    #
    def +(append)
      case append
      when Symbol
        t = text
        a = ansi + ANSICode.send(append)
      when self.class
        t = text + append.text
        a = ansi + append.ansi
      else
        t = text + append
        a = ansi + append
      end
      self.class.new(t, a)
    end

    #
    def <<(append)
      case append
      when Symbol
        @ansi << ANSICode.send(append)
      when self.class
        @text << append.text
        @ansi << append.ansi
      else
        @text << append
        @ansi << append
      end
    end

    #
    def size ; text.size ; end
    alias_method(:length, :size)

    # Give the string a color.
    def color(ansicolor=nil)
      self.class.new(text, ANSICode.send(ansicolor){ansi})
    end

    # Give the string a color.
    def color!(ansicolor=nil)
      @ansi = ANSICode.send(ansicolor){ansi}
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
        text.send(s, *a, &b)
        m = ansi.to_mask
        e = ansi.to_mask(ESC_RE)
        n = (e - m)
        e.instance_delegate.send(s,*a, &b)
        r = e + n
        @ansi = r.to_s
      else
        apply(s, *a, &b)
      end
    end

  private

    #
    def apply(s, *a, &b)
      t = text.send(s, *a, &b)
      m = ansi.to_mask
      e = ansi.to_mask(ESC_RE)
      n = (e - m)
      x = e.apply(s,*a, &b)
      r = x + n
      self.class.new(t, r.to_s)
    end

  end

end


=begin SPECIFICATION

  require 'quarry/spec'

  Quarry.spec "Clio::String" do

    s1 = Clio::String.new("Hi how are you.")
    s2 = Clio::String.new("Fine thanks.")

    verify "color" do
      r = s1.color(:red)
      e = Clio::ANSICode.red(s1.text)
      e.assert == r.to_s
    end

    verify "non-in-place delegation" do
      r = s1.upcase
      e = s1.text.upcase
      e.assert == r.to_s
    end

    verify "string addition" do
      r = s1 + s2
      e = s1.text + s2.text
    end

  end

=end

