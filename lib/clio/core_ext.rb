module Kernel

  # Anything that can be marshaled can be copied in totality.
  # This is also commonly called a deep_copy.
  #
  #   "ABC".copy  #=> "ABC"
  #
  def deep_copy
    Marshal::load(Marshal::dump(self))
  end

end

class String

  # Indent left or right by n spaces.
  # (This used to be called #tab and aliased as #indent.)

  def indent(n)
    if n >= 0
      gsub(/^/, ' ' * n)
    else
      gsub(/^ {0,#{-n}}/, "")
    end
  end

  # Preserves relative tabbing.
  # The first non-empty line ends up with n spaces before nonspace.

  def tabto(n)
    if self =~ /^( *)\S/
      indent(n - $1.length)
    else
      self
    end
  end

end

