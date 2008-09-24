module Clio

  class Commandline

    # = Commandline Option
    #
    class Option

      def initialize(parent, name, *aliases)
        name = name.to_s
        name = name.sub(/^[-]+/, '')
        @parent   = parent
        @flag     = (name.to_s[-1,1] == '?')
        @name     = name.to_s.chomp('?').to_sym
        @aliases  = aliases.collect{ |s| s.to_s.sub(/^[-]+/, '').to_sym }
        @help     = ''
        @type     = nil
        @multiple = false
        @exclude  = []
      end

      attr :name
      attr :aliases

      def help(string=nil)
        return @help unless string
        @help.replace(string.to_s)
        self
      end

      def type(string=nil)
        return @type unless string
        @type = string
        self
      end

      # Can the option be used multiple times?
      def multiple(bool=nil)
        return @multiple if bool.nil?
        @multiple = bool
        self
      end

      def xor(*opts)
        @exclude.concat(opts)
      end

      #
      def |(rest)
        [self, rest]
      end

      #
      def method_missing(s, *a)
        s = s.to_s
        @parent.__send__(s, *a)
      end

      #
      def to_s
        s = []
        s << (@name.to_s.size == 1 ? "-#{@name}" : "--#{@name}")
        @aliases.each do |a|
          s << (a.to_s.size == 1 ? "-#{a}" : "--#{a}")
        end
        s.join(' | ')
      end
    end

  end #class Option

end #module Clio

