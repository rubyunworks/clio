#require 'facets/array/indexable'

module Clio

  class Commandline
    require 'clio/commandline/option'
    require 'clio/commandline/argument'

    # = Commandline Command
    #
    class Command
      attr :name
      attr :arguments
      attr :commands
      attr :options
      #attr :modes     # common options
      attr :help

      #
      def initialize(name=nil, &block)
        @name = name.to_s.strip.to_sym
        @commands  = {}
        @arguments = {}
        @options   = {}
        #@modes    = {}
        @help      = ''

        instance_eval(&block) if block
      end

      # Define a command.
      #
      #   command(:document)
      #
      def command(name, &block)
        cmd = @commands[name.to_sym] ||= Command.new(name)
        cmd.instance_eval(&block) if block
        cmd
      end

      #alias_method :[], :command

      # Define an option.
      #
      #   option(:output, :o)
      #
      def option(name, *aliases)
        name = name.to_s
        name = name.gsub(/^[-]+/, '')
        name = name.to_sym
        @options[name] ||= Option.new(self, name, *aliases)
      end

      #
      def argument(name)
        @arguments[name.to_sym] ||= Argument.new(self, name)
      end

      #
      def help(string=nil)
        @help.replace(string.to_s) if string
        @help
      end

      # SHORTHAND NOTATION
      #-------------------------------------------------------------

      # Command shorthand.
      #
      #   cmd('document', 'generate documentation')
      #
      def cmd(name, help=nil, &block)
        command(name, &block).help(help)
      end

      # Option shorthand.
      #
      #   opt('--output=FILE -o', 'output directory')
      #
      def opt(name, help=nil)
        name, *aliases = name.split(/\s+/)
        name, type = *name.split('=')
        mult = false
        if type && type[0,1] == '*'
          mult = true
          type = type[1..-1]
        end
        o = option(name, *aliases)
        o.help(help) if help
        o.type(type) if type
        o.multiple(mult)
        self
      end

      # Argument shorthand.
      #
      #   arg('PIN', 'pin number')
      #
      def arg(slot, help=nil)
        argument(slot).help(help)
      end

      #def mode(name, *aliases)
      #  @modes[name.to_sym] ||= Option.new(self, name, *aliases)
      #end

      # ARRAY NOTATION
      #-------------------------------------------------------------

      #
      def [](*args)
        res = nil
        head, *tail = *args
        case head.to_s
        when /^-/
          x = []
          opts = args.map do |o|
            o = o.to_s
            if i = o.index('=')
              x << o[i+1..-1]
              o[0...i]
            else
              o
            end
          end
          x = x.uniq

          res = opt(*opts)
        else
          args.each do |name|
            res = command(name)
          end
        end
        return res
      end

      #
      #def method_missing(s, *a)
      #  #s = s.to_s
      #  option!(s, *a)
      #end

      #
      def to_s
        s = @name ? [@name] : []
        s.concat(@options.values.collect{ |o| "[#{o}]" })
        s << @commands.values.join(' & ')  unless @commands.empty?
        s << @arguments.values.join(' & ') unless @arguments.empty?
        s.flatten.join(' ')
      end

      def to_s_help
        s = []
        s << "USAGE"
        s << "  " + to_s
        unless help.empty?
          s << help
          s << ''
        end
        unless commands.empty?
          s << ''
          s << 'COMMANDS'
          s.concat(@commands.values.collect{ |x| "  %-20s %s" % [x.name, x.help] })
        end
        unless arguments.empty?
          s << ''
          s << "ARGUMENTS"
          s.concat(@arguments.values.collect{ |x| "  %-20s %s" % [x, x.help] })
        end
        unless options.empty?
          s << ''
          s << 'OPTIONS'
          s.concat(@options.values.collect{ |x| "  %-20s %s" % [x, x.help] })
        end
        s.flatten.join("\n")
      end

      #
      #def &(*rest)
      #  [self, *rest]
      #end

    end #class Command

  end #class Commandline

end #module Clio

