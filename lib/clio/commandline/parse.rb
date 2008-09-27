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

      attr :options
      attr :arguments
      attr :subcommand

      #
      def initialize(usage, argv, index=0)
        @usage = usage
        @argv  = argv
        @index = index

        @options    = {}
        @arguments  = []
        @subcommand = nil
      end

      def key; usage.key; end

      #
      def inspect
        s = "<" + arguments.inspect + " " + options.inspect
        s << " #{@subcommand.key} #{@subcommand.inspect}" if @subcommand
        s << ">"
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
        @options    = {}
        @arguments  = []
        @subcommand = nil

        i = @index

        while i < argv.size
          case a = argv[i]
          when /^[-]/
            res = parse_option(a, i)
            i += 1 unless a.index('=')
          else
            if arguments.size < usage.arguments.size
              res = parse_argument(a, i)
            else
              res = parse_command(a, i)
              break
            end
          end
          i += 1
        end
        # okay, now what if there are left over arguments?
        return res
      end


    private

      #
      def parse_option(opt, index)
        #opt = opt.sub(/^[-]*/, '')
        name, val = *opt.split('=')
        if use = usage.option?(name.to_sym)
          if use.flag?
            val = val || true
          else
            val = argv[index+1] unless val
          end
          options[use.name] = val  # TODO: what about aliases? Need to just get the one option.
        else
          raise Error, "unknown option #{opt} for #{usage.name} command"
        end
      end

      #
      def parse_argument(arg, index)
        arguments << arg
      end

      #
      def parse_command(cmd, index)
        if use = usage.commands[cmd.to_sym]
          @subcommand = Parse.new(use, argv, index+1)
          begin
            @subcommand.parse
          rescue
            return @subcommand
          end
        else
          raise Error, "unknown command #{cmd} for #{usage.name} command"
        end
        @subcommand
      end

      #
      class Error < StandardError
      end

    end #class Parse

  end #class Commandline

end #module Clio


