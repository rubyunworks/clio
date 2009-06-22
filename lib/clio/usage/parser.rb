require 'shellwords'
#require 'clio/usage/signature'
require 'clio/usage/interface'

module Clio

  class Usage #:nodoc:

    # = Parser
    #
    # Parse commandline arguments according to given Usage.
    #
    class Parser
      attr :usage
      #attr :argv

      #attr :signatures

      #
      def initialize(usage) #, argv) #, index=0)
        @usage  = usage
        #@argv   = argv

        #@parsed     = false
        #@signatures = []
        #@errors     = []
      end

      #
      def name ; usage.name ; end
      def key  ; usage.key  ; end

      #
      def clean_vector(args)
        # convert to array if argv string
        if ::String===args
          argv = Shellwords.shellwords(args)
        else
          argv = args.to_a.dup
        end
        #@argv = argv
      end

      #
      #def inspect
      #  s  = "#<#{self.class}"
      #  s << " @options=#{@options.inspect}" unless @options.empty?
      #  s << " @arguments=#{@arguments.inspect}" unless @arguments.empty?
      #  s << " @subcommand=#{@subcommand}>" if @subcommand
      #  s << ">"
      #  s
      #end

      #
      def parse(args=nil)
        argv = clean_vector(args)

        @parsed     = false

        #@signatures = []

        @commands  = []
        @options   = {}
        @arguments = []

        @errors    = []

        parse_command(usage, argv)

        @parsed     = true

        return Interface.new(@commands, @options, @arguments, @errors)
        #return Interface.new(@signatures, @errors)
      end

      # Has the commandline been parsed?
      def parsed? ; @parsed ; end

    private

      # TODO: clean-up parsing
      def parse_command(usage, argv)
        op = {}
        ar = []
        cm = nil

        #greedy = parse_greedy(usage, argv)

        #options.update(greedy)

        until argv.empty?
          use, val = parse_option(usage, argv)
          if use
#p "use: #{use.key}, #{val}"
            if val == "\t"
              parse_errors << [val, use]
            elsif use.multiple?
              op[use.key] ||= []
              op[use.key] << val
            else
              op[use.key] = val
            end
          elsif !usage.arguments.empty?
            usage.arguments.each do |a|
              if a.splat
                while argv.first && argv.first !~ /^[-]/
                  ar << argv.shift
                end
                break if argv.empty?
              else
                ar << argv.shift
              end
            end
          else
            break if argv.empty?
            arg = argv.shift
            use = usage.commands.find{|c| c === arg}
            if use
              parse_command(use, argv)
              break
            else
#arguments << arg
              errors << [arg, usage]
              #raise ParseError, "unknown command or argument #{a} for #{usage.key} command"
              break
            end
          end
        end

        @commands.unshift(usage.name)
        @options.update(op)
        @arguments.concat(ar)

        #@signatures.unshift(Signature.new(usage.name, arguments, options))
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
        # if the current arg is '--' then this is a stopping point.
        return if argv.first =~ /^[-]+$/
        # if not an option then move on.
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
          errors << [arg, usage.key]
        end
        return use, val
      end

    public

      #
      def errors
        @errors
      end

      #alias_method :parse_errors, :errors

    end #class Parser

    #
    class ParseError < StandardError
    end

  end #class Usage

end #module Clio

