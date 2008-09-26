module Clio

  class Commandline

    # = Parse
    #
    # Parse the commandline according to given
    # Usage.
    #
    class Parse
      instance_methods.each do |m|
        private m if m !~ /^(__|instance_|object_|send$|inspect$|respond_to\?$)/
      end

      attr :argv
      attr :usage

      attr :options
      attr :arguments
      attr :subcommand

      #
      def initialize(usage, argv=nil)
        @usage = usage

        @argv = if String === argv
          Shellwords.shellwords(argv)
        else
          argv || ARGV
        end

        @options    = {}
        @arguments  = []
        @subcommand = []
      end

      #
      def parse(index=0)
        @options    = {}
        @arguments  = []
        @subcommand = []

        i = index
        while i < argv.size
          a = argv[i]
          case a
          when /^[-]/
            parse_option(a, index)
            i += 1 unless a.index('=')
          else
            if arguments.size < usage.arguments.size
              parse_argument(a, index)
            else
              parse_command(a, index)
              break
            end
          end
          i += 1
        end
        # okay, now what if there are left over argv's?
      end

      #
      def method_missing(s, *a)
        s = s.to_s
        case s
        when /[=]$/
          n = s.chomp('=')
          usage.option(n).type(*a)
          parse
          options[n.to_sym]
        when /[!]$/
          usage.command(s, *a)
          parse
          subcommand
        when /[?]$/
          n = s.chomp('?')
          usage.option(s, *a)
          parse
          options[n.to_sym]
        else
          usage.option(s, *a)
          parse
          options[s.to_sym]
        end
      end

    private

      #
      def parse_option(opt, index)
        opt = opt.sub(/^[-]*/, '')
        name, val = *opt.split('=')
        if use = usage.options[name.to_sym] || usage.option_aliases[name.to_sym] #TODO: what about aliases?
          if use.flag?
            val = val || true
          else
            val = argv[index+1] unless val
          end
          options[use.name] = val  # TODO: what about aliases? Need to just get the one option.
        else
          raise "unknown option #{opt} for #{usage.name} command"
        end
      end

      #
      def parse_argument(arg, index)
        arguments << arg
      end

      #
      def parse_command(cmd, index)
        if use = usage.commands[cmd.to_sym]
          @subcommand = Parse.new(use, argv).parse(index + 1)
        else
          raise "unknown command #{cmd} for #{usage.name} command"
        end
      end

    end #class Parse

  end #class Commandline

end #module Clio


