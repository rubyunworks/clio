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
        @aliases  = []
        @help     = ''
        @type     = nil
        @multiple = false
        @exclude  = []

        aliases.each{ |a| alia(a) }
      end

      attr :name
      attr :aliases

      def flag? ; @flag ; end

      def help(string=nil)
        return @help unless string
        @help.replace(string.to_s)
        self
      end

      def alia(name)
        name = name.to_s
        name = name.sub(/^[-]+/, '')
        name = name.chomp('?')
        name = name.to_sym 
        @aliases << name
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

      ### Parse an option.
      ###
      ### Commandline arguments (argv) are passed into this method
      ### and are changed in placed as they are parsed.
      def parse(argv)
        f = flag ? 'flag' : 'value'
        r = []
        [name, *aliases].each do |n|
          k = n.to_s.size == 1 ? 'letter' : 'word'
          r << send("parse_#{f}_#{k}", argv, n)
        end
        return r.first
      end

    end #class Option

  end #class Commandline

end #module Clio

