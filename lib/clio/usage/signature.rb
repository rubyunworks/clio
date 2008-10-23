module Clio

  module Usage

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

    end#class Signature

  end#module Usage

end#module Clio

