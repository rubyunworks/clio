module Clio

  module Usage #:nodoc:

    # = Usage Argument
    #
    class Argument
      #attr :parent
      attr :name
      attr :type
      attr :help
      attr :splat

      # New Argument.
      #def initialize(name, parent=nil, &block)
      def initialize(name, &block)
        @name      = name.to_s
        @type      = name.upcase
        #@parent    = parent
        @splat     = false
        @help      = ''
        instance_eval(&block) if block
      end

      #
      def initialize_copy(o)
        @name = o.name.dup
        @type = o.type.dup
        @help = o.help.dup
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

      #
      def splat(true_or_false=nil)
        return @splat if true_or_false.nil?
        @splat = true_or_false
      end

      # Specify help text for argument.
      def help(string=nil)
        @help.replace(string.to_s) if string
        @help
      end

      def to_s
        if name.upcase == type
          s = "<#{name}"
        else
          s = "<#{name}:#{type}"
        end
        s << (splat ? "...>" : ">")
        s
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

