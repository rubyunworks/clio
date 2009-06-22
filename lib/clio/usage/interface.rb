module Clio

  class Usage

    # = Command Interface (toplevel signature)
    #
    # The end result provide by Usage::Parser#parse.
    # This class consists of an array of command signatures
    # and parse errors.
    #
    class Interface

      #attr :signatures

      attr :commands

      attr :arguments

      attr :options

      attr :errors

      alias_method :switches, :options

      #alias_method :parse_errors, :errors

      #
      #def initialize(signatures=[], errors=[])
      def initialize(commands, options, arguments, errors=[])
        @binary    = commands[0]
        @commands  = commands[1..-1]
        @options   = options
        @arguments = arguments

        #@signatures = signatures
        @errors     = errors
      end

      #def inspect; "#<#{self.class}:" + @signature.inspect + ">"; end

      # TODO: join by what character?
      def command
        return nil if commands.empty?
        return commands.join(' ')
      end

#      #
#      def commands
#        #parse unless parsed?
#        @commands ||= (
#          a = []
#          @signatures[1..-1].each do |s|
#            a << s.command.to_s
#          end
#          a
#        )
#      end


#      #
#      def options
#        #parse unless parsed?
#        @options ||= (
#          h = {}
#          @signatures.each do |s|
#            h.merge!(s.options)
#          end
#          h
#        )
#      end
#      alias_method :switches, :options


#      #
#      def arguments
#        #parse unless parsed?
#        @arguments ||= (
#          m = []
#          @signatures.each do |s|
#            m.concat(s.arguments)
#          end
#          m
#        )
#      end



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
        case i
        when Numeric
          @arguments[i]
        else
          @options[i]
        end
        #@signatures[i]
      end

      #
      def to_a
        #parse unless parsed?
        #@signatures.collect{ |s| s.to_a }
        parameters
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

