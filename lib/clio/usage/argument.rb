module Clio

  class Usage #:nodoc:

    # = Usage Argument
    #
    # TODO: Should argument have name in addition to type?
    class Argument
      #attr :parent
      #attr :name
      attr :type
      attr :desc
      attr :splat

      # New Argument.
      def initialize(type, &block)
        @type      = type
        #@name      = type.downcase if type.upcase != type
        @splat     = false
        @desc      = ''
        instance_eval(&block) if block
      end

      #
      def initialize_copy(o)
        #@name = o.name.dup
        @type = o.type.dup
        @desc = o.desc.dup
      end

      # Same as +name+ but given as a symbol.
      #def key
      #  name.to_sym
      #end

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

      #def name(string=nil)
      #  return @name unless string
      #  @name = string.to_s
      #  self
      #end

      #
      def splat(true_or_false=nil)
        return @splat if true_or_false.nil?
        @splat = true_or_false
      end

      # Specify desc text for argument.
      def desc(string=nil)
        @desc.replace(string.to_s) if string
        @desc
      end
      alias_method :description, :desc

      def to_s
        s = "<#{type}"
        s << (splat ? "...>" : ">")
        s
      end

      def inspect
        to_s
        #s  = "<#{name}"
        #s << ":#{type.inspect}" if type
        #s << ">"
        #s
      end

    end #class Argument

  end #module Usage

end #module Clio

