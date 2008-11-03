module Clio

  module Usage

    # = Command Interface (toplevel signature)
    #
    # The end result provide by Usage::Parser#parse.
    # This class consists of an array of command signatures
    # and parse errors.
    #
    class Interface

      attr :signatures
      attr :errors

      alias_method :parse_errors, :errors

      #
      def initialize(signatures=[], errors=[])
        @signatures = signatures
        @errors     = errors
      end

      # TODO: Join by what character?
      def command
        return nil if commands.empty?
        return commands.join('/')
      end

      #
      def commands
        #parse unless parsed?
        @commands ||= (
          a = []
          @signatures[1..-1].each do |s|
            a << s.command
          end
          a
        )
      end        

      #
      def options
        #parse unless parsed?
        @options ||= (
          h = {}
          @signatures.each do |s|
            h.merge!(s.options)
          end
          h
        )
      end
      alias_method :switches, :options

      #
      def arguments
        #parse unless parsed?
        @arguments ||= (
          m = []
          @signatures.each do |s|
            m.concat(s.arguments)
          end
          m
        )
      end

      # Return parameters array of [*arguments, options]
      def parameters
        arguments + [options]
      end

      #def signatures
      #  parse unless parsed?
      #  a = [[usage, arguments, options]]
      #  a += command.signatures if command
      #  a
      #end

      # Were the commandline arguments valid?
      # This simply checks to see if there were
      # any parse errors.
      def valid?
        #parse unless @parsed
        errors.empty?
      end

      # Index on each subcommand, with 0 being the toplevel command.
      def [](i)
        @signatures[i]
      end

      #
      def to_a
        #parse unless parsed?
        @signatures.collect{ |s| s.to_a }
      end

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

    end#class Interface

  end#module Usage

end#module Clio

