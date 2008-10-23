module Clio

  module Usage

    # = Usage Argument
    #
    class Argument
      attr :parent
      attr :name
      attr :type
      attr :help

      # New Argument.
      def initialize(name, parent=nil, &block)
        @name      = name.to_s
        @type      = key.to_s.upcase
        @parent    = parent
        @help      = ''
        instance_eval(&block) if block
      end

      # Same as +name+ but given as a symbol.
      def key
        name.to_sym
      end

      # Specify the type of the argument.
      # This is an arbitrary description of the type.
      # The value given is converted to uppercase.
      #
      #   arg.type('file')
      #   arg.type #=> 'FILE'
      #
      def type(string=nil)
        return @type unless string
        @type = string.to_s.upcase
        self
      end

      # Specify help text for argument.
      def help(string=nil)
        @help.replace(string.to_s) if string
        @help
      end

      def to_s
        "<#{name}>"
      end

      def inspect
        s  = "<#{name}"
        s << ":#{type.inspect}" if type
        s << ">"
        s
      end

    end #class Argument

  end #module Usage

end #module Clio

