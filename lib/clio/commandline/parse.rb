module Clio

  class Commandline

    # = Parse
    #
    # Parse the commandline according to given
    # Usage.
    #
    class Parse
      attr :usage
      attr :argv
      attr :index

      attr :signatures

      #
      def initialize(usage, argv, index=0)
        @usage  = usage
        @argv   = argv
        @index  = index
        reset!
      end

      #
      def reset!
        @parsed     = false
        @command    = nil # usage.key
        @options    = nil
        @arguments  = nil
        @signatures = []
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
        reset!
        parse_command(usage, argv.dup)
        @parsed = true
      end

      # Has the commandline been parsed?
      def parsed? ; @parsed ; end

    private

      # TODO: clean-up parsing

      def parse_command(usage, argv)
        options    = {}
        arguments  = []
        command    = nil

        greedy = parse_greedy(usage, argv)

        options.update(greedy)

        until argv.empty?
          use, val = parse_option(usage, argv)
          if use
            if use.multiple?
              options[use.key] ||= []
              options[use.key] << val
            else
              options[use.key] = val
            end
          elsif arguments.size < usage.arguments.size
            arguments << argv.shift
          else
            arg = argv.shift
            use = usage.commands.find{|c| c === arg}
            if use
              parse_command(use, argv)
              break
            else
              parse_errors << [arg, usage.key]
              #raise ParseError, "unknown command or argument #{a} for #{usage.key} command"
              break
            end
          end
        end

        @signatures.unshift(Signature.new(usage.key, arguments, options))
      end

      # Parse greedy options. This function loops thru ARGV and 
      # removes any matching greedy options.
      def parse_greedy(usage, argv)
        switches = {}
        d, i = [], 0
        while i < argv.size
          case a = argv[i]
          when /^[-]/
            #res = parse_option(a, i)
            name, val = *a.split('=')
            use = usage.option?(name)
            if use && use.greedy?
              del << i
              if use.flag?
                val = val || true
              else
                val = argv[i+1] unless val
                i += 1
                d << i
              end
              switches[use.name] = val
            end
            res = val
          end
          i += 1
        end
        d.each{ |i| argv[i] = nil }
        argv.compact!
        return switches
      end

      #
      def parse_option(usage, argv)
        return if argv.first !~ /(^-|=)/
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

      #
      def parse_errors
        @parse_errors ||= []
      end

      def valid?
        parse unless @parsed
        parse_errors.empty?
      end

    public

      #def signatures
      #  parse unless parsed?
      #  a = [[usage, arguments, options]]
      #  a += command.signatures if command
      #  a
      #end

      def [](i)
        @signatures[i]
      end

      # Return parameters array of [*arguments, options]
      def parameters
        arguments + [options]
      end

      #
      def to_a
        parse unless parsed?
        @signatures.collect{ |s| s.to_a }
      end

      # TODO: Join by what character?
      def command
        return nil if commands.empty?
        return commands.join('/')
      end

      #
      def commands
        parse unless parsed?
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
        parse unless parsed?
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
        parse unless parsed?
        @arguments ||= (
          m = []
          @signatures.each do |s|
            m.concat(s.arguments)
          end
          m
        )
      end

      # = Command Signature
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
      end

    end #class Parse

    #
    class ParseError < StandardError
    end

  end #class Commandline

end #module Clio


