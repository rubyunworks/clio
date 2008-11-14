require 'shellwords'
require 'clio/usage/signature'
require 'clio/usage/interface'

module Clio

  module Usage #:nodoc:

    # = Parser
    #
    # Parse commandline arguments according to given Usage.
    #
    class Parser
      attr :usage
      attr :argv

      attr :signatures

      #
      def initialize(usage, argv) #, index=0)
        # convert to array if argv string
        if String===argv
          argv = Shellwords.shellwords(argv)
        else
          argv = argv.dup
        end

        @usage  = usage
        @argv   = argv

        @parsed     = false
        @signatures = []
        @errors     = []
      end

      #
      def name ; usage.name ; end
      def key  ; usage.key  ; end

      #
      def inspect
        s = "<" + signatures.inspect + ">"
        s
        #s  = "#<#{self.class}"
        #s << " @options=#{@options.inspect}" unless @options.empty?
        #s << " @arguments=#{@arguments.inspect}" unless @arguments.empty?
        #s << " @subcommand=#{@subcommand}>" if @subcommand
        #s << ">"
        #s
      end

      #
      def parse
        @parsed     = false
        @signatures = []
        @errors     = []

        parse_command(usage, argv.dup)

        @parsed     = true

        return Interface.new(@signatures, @errors)
      end

      # Has the commandline been parsed?
      def parsed? ; @parsed ; end

    private

      # TODO: clean-up parsing
      def parse_command(usage, argv)
        options    = {}
        arguments  = []
        command    = nil

        #greedy = parse_greedy(usage, argv)

        #options.update(greedy)

        until argv.empty?
          use, val = parse_option(usage, argv)
          if use
#p "use: #{use.key}, #{val}"
            if val == "\t"
              parse_errors << [val, use]
            elsif use.multiple?
              options[use.key] ||= []
              options[use.key] << val
            else
              options[use.key] = val
            end
          elsif arguments.size < usage.arguments.size
            arg = argv.shift
#p "arg: #{arg}"
            arguments << arg
          else
            break if argv.empty?
            arg = argv.shift
            use = usage.commands.find{|c| c === arg}
            if use
              parse_command(use, argv)
              break
            else
              parse_errors << [arg, usage]
              #raise ParseError, "unknown command or argument #{a} for #{usage.key} command"
              break
            end
          end
        end
        @signatures.unshift(Signature.new(usage.name, arguments, options))
      end

=begin
      # Parse greedy options. This function loops thru ARGV and
      # removes any matching greedy options.
      def parse_greedy(usage, argv)
        options = {}
        d, i = [], 0
        while i < argv.size
          case a = argv[i]
          when /^[-].+/
            #res = parse_option(a, i)
            name, val = *a.split('=')
            use = usage.greedy_option?(name)
            if use && use.greedy?
              d << i
              if use.flag?
                val = val || true
              else
                val = argv[i+1] unless val
                i += 1
                d << i
              end
              options[use.key] = val
            end
            res = val
          end
          i += 1
        end
        d.each{ |i| argv[i] = nil }
        argv.compact!
        return options
      end
=end

      #
      def parse_option(usage, argv)
        return if argv.first =~ /^[-]+$/
        return if argv.first !~ /(^-.+|=)/
        arg = argv.shift
        name, val = *arg.split('=')
        if use = usage.option?(name)
          if use.flag?
            val = true unless val
          else
            val = argv.shift unless val
          end
          #options[use.name] = val
        else
          parse_errors << [arg, usage.key]
        end
        return use, val
      end

    public

      #
      def errors
        @errors
      end

      alias_method :parse_errors, :errors

    end #class Parser

    #
    class ParseError < StandardError
    end

  end #class Usage

end #module Clio


