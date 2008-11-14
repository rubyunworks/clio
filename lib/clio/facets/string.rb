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
