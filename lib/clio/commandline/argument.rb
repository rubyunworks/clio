module Clio

  class Commandline

    # = Commandline Argument
    #
    # The Commandline Argument class is multipuposed,
    # in that it can represent any type of commandline
    # argument --a subcommand, an option or switch,
    # or just a plain argument. Unifying these types
    # of commandline entities, rather than spliting them
    # up into separate classes, makes for a more flexible
    # system.
    #
    class Argument

      attr :parent

      attr :key
      attr :name

      attr :commands
      attr :arguments
      attr :options
      attr :aliases

      attr :type
      attr :multiple
      attr :exclusive

      #attr :modes     # common options

      attr :help

      #
      def initialize(key, parent=nil, &block)
        @key  = key.to_s.strip.to_sym
        @name = clean_name(key)

        @parent = parent

        @aliases   = []
        @arguments = []

        @commands  = {}
        @options   = {}

        #@modes    = {}
        @help      = ''

        @type      = nil
        @multiple  = false
        @exclusive = []

        instance_eval(&block) if block
      end

      def inspect
        s  = "<#{self.class} @key=#{@key} @name=#{@name}"
        s << " @aliases=#{@aliases.inspect}>" unless @aliases.empty?
        s << " @commands=#{@commands.inspect}>" unless @commands.empty?
        s << " @options=#{@options.inspect}>" unless @options.empty?
        s << ">"
        s
      end

      def flag?; @type==nil; end

      # Define a command.
      #
      #   command(:document)
      #
      def command(name, &block)
        cmd = @commands[name.to_sym] ||= Argument.new(name, self)
        cmd.instance_eval(&block) if block
        cmd
      end

      #alias_method :[], :command

      # Define an option.
      #
      #   option(:--output, :o)
      #
      def option(name, *aliases, &block)
        #flag = flag_name?(name)
        #name = clean_option_name(name)
        key = option_key(name)
        opt = @options[key] ||= (
          arg = Argument.new(key, self)
          arg.aliases(*aliases)
          arg
        )
        opt.instance_eval(&block) if block
        opt
      end

      #
      def argument(name, &block)
        arg = Argument.new(name, self)
        arg.instance_eval(&block) if block
        @arguments << arg
        arg
      end

      #
      def aliases(*names)
        return @aliases if names.empty?
        names.each do |name|
          @aliases << option_key(name) #name.to_sym #clean_option_name(name)
        end
      end

      #
      def type(string=nil)
        return @type unless string
        @type = string
        self
      end

      # Can the option be used multiple times?
      def multiple(bool=nil)
        return @multiple if bool.nil?
        @multiple = bool
        self
      end

      def xor(*opts)
        @exclusive.concat(opts)
      end

      #
      def help(string=nil)
        @help.replace(string.to_s) if string
        @help
      end

      #

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
        s = [@key.to_s]
        @aliases.each do |a|
          s << a #.key
        end
        s.concat(@options.values.collect{ |o| "[#{o}]" })
        s << @commands.values.join(' & ')  unless @commands.empty?
        s << @arguments.join(' & ') unless @arguments.empty?
        s.flatten.join(' ')
      end

      #
      #def to_s
      #  s = []
      #  s << (@name.to_s.size == 1 ? "-#{@name}" : "--#{@name}")
      #  @aliases.each do |a|
      #    s << (a.to_s.size == 1 ? "-#{a}" : "--#{a}")
      #  end
      #  s.join(' | ')
      #end

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
          s.concat(@commands.values.collect{ |x| "  %-20s %s" % [x.key, x.help] })
        end
        unless arguments.empty?
          s << ''
          s << "ARGUMENTS"
          s.concat(@arguments.collect{ |x| "  %-20s %s" % [x, x.help] })
        end
        unless options.empty?
          s << ''
          s << 'OPTIONS'
          s.concat(@options.values.collect{ |x| "  %-20s %s" % [[x.key, *x.aliases].join(' '), x.help] })
        end
        s.flatten.join("\n")
      end

      #
      #def &(*rest)
      #  [self, *rest]
      #end

      #
      #def |(other)
      #  self.xor(other)
      #end

      #
      def option?(key)
        opt = options[key]
        return opt if opt
        options.each do |k, o|
          return o if o.aliases.include?(key)
        end
        nil
      end

    private

      def clean_name(key)
        key = key.to_s
        key = key.gsub(/^[-]+/, '')
        return key.chomp('?').to_sym
      end

      def flag_key?(key)
        name = key.to_s
        return key[-1,1] == '?'
      end

      def option_key(key)
        name = clean_name(key).to_s
        if name.size == 1
          "-#{name}".to_sym
        else
          "--#{name}".to_sym
        end
      end

    end #class Argument

=begin
      def initialize(parent, slot)
        @parent = parent
        @slot   = slot
      end

      def help(string=nil)
        @help.replace(string.to_s) if string
        @help
      end

      def to_s
        "#{slot}".upcase
      end
=end

  end #class Commandline

end #module Clio

