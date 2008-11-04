module Clio

  module Usage #:nodoc:

    # = Command Signature
    #
    # Used by the Usage::Parser as the end result
    # of parsing a Usage::Command.
    #
    class Signature
      def initialize(c, a, o)
        @signature  = [c, a, o]
        @command    = c
        @arguments  = a
        @options    = o
      end

      attr :command
      attr :arguments
      attr :options
      attr :signature

      def to_a; @signature; end

      def parameters
        @arguments + [@options]
      end

      def inspect; "#<#{self.class}:" + @signature.inspect + ">"; end

      #
      def method_missing(s, *a)
        s = s.to_s
        case s
        #when /[=]$/
        #  n = s.chomp('=')
        #  usage.option(n).type(*a)
        #  #parser.parse
        #  res = parser.options[n.to_sym]
        #when /[!]$/
        #  n = s.chomp('!')
        #  res = parser.parse
        when /[?]$/
          options[s.chomp('?').to_sym]
        else
          options[s.to_sym]
        end
      end

    end#class Signature

  end#module Usage

end#module Clio

