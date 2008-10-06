module Clio

  class Commandline

    # = Commandline Argument
    #
    class Argument
      attr :parent

      attr :key
      attr :type

      attr :help

      #
      def initialize(key, parent=nil, &block)
        @key       = key.to_sym
        @parent    = parent
        @type      = nil
        @help      = ''
        instance_eval(&block) if block
      end

      def inspect
        s  = "<#{key}"
        s << ":#{type.inspect}" if type
        s << ">"
        s
      end

      def to_s
        "<#{key}>"
      end

      #
      def type(string=nil)
        return @type unless string
        @type = string
        self
      end

      #
      def help(string=nil)
        @help.replace(string.to_s) if string
        @help
      end

    end #class Argument

  end #class Commandline

end #module Clio

