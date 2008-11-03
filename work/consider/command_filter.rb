# UNDER CONSTRUCTION

# The idea here is a convenient way
# to transform on ARGV into another.

class CommandFilter

  def initialize(line=ARGV)
    case line
    when String
      @args = Shellwords.parse(argv)
    else
      @args = line
    end
    @cons = []
  end

end

