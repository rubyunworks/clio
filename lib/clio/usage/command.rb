require 'clio/usage/option'
require 'clio/usage/argument'

module Clio

  module Usage

    # = Commandline Usage Command
    #
    # This is the primary Usage class; subclassed by Main and
    # containing together Options and Arguments.
    #
    # Commands cannot have both arguments and subcommands. While
    # it is technically parsable (an older version of Commandline
    # allowed it), when using a command it proves too easy to
    # accidently omit an argument and have a subcommand take
    # its place, causing erroneous behavior. I looked through
    # a number of other commandline tools and never once found a
    # case of subcommands following arguments, so it was decided
    # to purposely limit Commandline in this fashion.
    #
    class Command
      attr :parent
      attr :name

      attr :commands
      attr :options  # TODO: Combine options and switches
      attr :switches
      attr :arguments

      attr :help

      #
      def initialize(name, parent=nil, &block)
        @name       = name.to_s
        @parent     = parent
        @commands   = []
        @options    = []
        @switches   = []
        @arguments  = []
        @help       = ''
        instance_eval(&block) if block
      end

      def key ; @name.to_sym ; end

      # METHOD MISSING
      #-------------------------------------------------------------

      def method_missing(name, *args, &blk)
        name = name.to_s
        case name
        when /\?$/
          option(name.chomp('?'), *args, &blk)
        else
          c = command(name, &blk)
          args.each{ |a| c[a] }
          c
        end
      end

      def help!(*args)
        Hash[*args].each do |key, desc|
          self[key, desc]
        end
      end


      # LONGHAND NOTATION
      #-------------------------------------------------------------

      # Define a command.
      #
      #   command('remote')
      #   command('remote','add')
      #
      def command(name, &block)
        raise "Command cannot have both arguments and subcommands (eg. #{name})." unless arguments.empty?
        key = name.to_s.strip
        if cmd = @commands.find{|c| c === key}
        else
          cmd = Command.new(key, self)
          @commands << cmd
        end
        cmd.instance_eval(&block) if block
        cmd
      end

      # Define an option.
      #
      #   option(:output, :o)
      #
      def option(name, *aliases, &block)
        if opt = @options.find{|o| o === name}
        else
          opt = Option.new(name, self)
          opt.aliases(*aliases)
          @options << opt
        end
        opt.instance_eval(&block) if block
        opt
      end

      # A switch is like an option, but it is greedy.
      # When parsed it will pick-up any match subsequent
      # the switch's parent command. In other words,
      # switches are consumed by a command even if they
      # appear in a subcommand's arguments.
      #
      def switch(name, *aliases, &block)
        if opt = @switches.find{|o| o === name}
        else
          opt = Option.new(name, self)
          opt.greedy = true
          opt.aliases(*aliases)
          @switches << opt
        end
        opt.instance_eval(&block) if block
        opt
      end

      # Define an argument.
      # Takes a name, optional index and block.
      #
      # Indexing of arguments starts at 1, not 0.
      #
      # Examples
      #
      #   argument(:path)
      #   argument(1, :path)
      #
      def argument(n1, n2=nil, &block)
        if Integer===n1
          index, type = n1, n2
        else
          type  = n1
          index = @arguments.size + 1
        end
        index = index - 1

        raise "Command cannot have both arguments (eg. #{type}) and subcommands." unless commands.empty?

        if type || block
          if arg = @arguments[index]
            arg.type(type)
            arg.instance_eval(&block) if block
          else
            @arguments[index] = Argument.new(type, self, &block)
          end
        end

        return @arguments[index]
      end

      #
      def help(string=nil)
        @help.replace(string.to_s) if string
        @help
      end

      # SHORTHAND NOTATION
      #-------------------------------------------------------------

      # Super shorthand notation.
      #
      #   cli['document']['--output=FILE -o']['<files>']
      #
      def [](*x)
        case x[0].to_s[0,1]
        when '-'
          opt(*x)
        when '<'
          arg(*x)
        else
          cmd(*x)
        end
      end

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
        name = clean_name(name)
        o = option(name, *aliases)
        o.help(help) if help
        o.argument(type) if type
        o.multiple(mult)
        self
      end

      # Switch shorthand.
      #
      #   swt('--output=FILE -o', 'output directory')
      #
      def swt(name, help=nil)
        name, *aliases = name.split(/\s+/)
        name, type = *name.split('=')
        mult = false
        if type && type[0,1] == '*'
          mult = true
          type = type[1..-1]
        end
        name = clean_name(name)
        o = switch(name, *aliases)
        o.help(help) if help
        o.argument(type) if type
        o.multiple(mult)
        self
      end

      # Argument shorthand.
      #
      #   arg('PIN', 'pin number')
      #
      def arg(type=nil, help=nil)
        type = type.to_s.sub(/^\</,'').chomp('>')
        argument(type).help(help)
      end

      # QUERY METHODS
      #-------------------------------------------------------------

      #
      def completion
        if commands.empty?
          arguments.collect{|c| c.key}
        else
          commands.collect{|c| c.name}
        end
      end

      # Option defined?
      #
      def option?(key)
        options.find{|o| o === key}
        #return opt if opt
        #options.each do |o|
        #  return o if o.aliases.include?(key)
        #end
        #nil
      end

      # Greedy Option defined?
      #
      def greedy_option?(key)
        switches.find{|o| o === key}
      end

      #
      def ===(other_name)
        name == other_name.to_s
      end

      #
      def inspect
        s = ''
        s << "#<#{self.class}:#{object_id} #{@name} "
        s << "@arguments=#{@arguments.inspect} " unless @arguments.empty?
        s << "@options=#{@options.inspect} "     unless @options.empty?
        s << "@switches=#{@switches.inspect} "   unless @switches.empty?
        s << "@help=#{@help.inspect}"            unless @help.empty?
        #s << "@commands=#{@commands.inspect} "  unless @commands.empty?
        s
      end

      # Full callable command name.
      def full_name
        if parent
          "#{parent.full_name} #{name}"
        else
          "#{name}"
        end
      end

      # Usage text.
      #
      def to_s
        #s = [full_name]
        s = [name]

        case options.size
        when 0
        when 1, 2, 3
          s.concat(options.collect{ |o| "[#{o.to_s.strip}]" })
        else
          s << "[switches]"
        end
# switches? vs. options
        s << arguments.join(' ') unless arguments.empty?

        case commands.size
        when 0
        when 1
          s << commands.join('')
        when 2, 3
          s << '[' + commands.join(' | ') + ']'
        else
          s << 'command'
        end

        s.flatten.join(' ')
      end

      # Help text.
      #
      def to_s_help
        s = []
        unless help.empty?
          s << help
          s << ''
        end
        s << "Usage:"
        s << "  " + to_s
        unless commands.empty?
          s << ''
          s << 'Commands:'
          s.concat(commands.collect{ |x| "  %-20s %s" % [x.key, x.help] }.sort)
        end
        unless arguments.empty?
          s << ''
          s << "Arguments:"
          s.concat(arguments.collect{ |x| "  %-20s %s" % [x, x.help] })
        end
        unless options.empty?
          s << ''
          s << 'Switches:'
          s.concat(options.collect{ |x| "  %-20s %s" % [x, x.help] })
        end
        s.flatten.join("\n")
      end

      # PARSE
      #-------------------------------------------------------------

      # Parse usage.
      def parse(argv, index=0)
        @parser ||= Parser.new(self, argv, index)
        @parser.parse
      end

    private

      def option_key(key)
        name = clean_name(key).to_s
        if name.size == 1
          "-#{name}".to_sym
        else
          "--#{name}".to_sym
        end
      end

      def clean_name(key)
        key = key.to_s
        key = key.gsub(/^[-]+/, '')
        return key.chomp('?').to_sym
      end

    end #class Command

  end #module Usage

end #module Clio

