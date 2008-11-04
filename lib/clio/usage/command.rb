require 'clio/usage/option'
require 'clio/usage/argument'

module Clio

  module Usage #:nodoc:

    # = Commandline Usage Command
    #
    # This is the heart of usage; subclassed by Main and
    # containing together Options and Arguments.
    #
    #   usage = Usage.new
    #
    class Command
      attr :parent

      attr :name

      attr :subcommands
      attr :options
      attr :arguments

      attr :help

      alias_method :switches, :options

      #
      def initialize(name, parent=nil, &block)
        @name       = name.to_s
        @parent     = parent
        @subcommands   = []
        @options    = []
        @arguments  = []
        @help       = ''
        instance_eval(&block) if block
      end

      def key ; @name.to_sym ; end

      # METHOD MISSING
      #-------------------------------------------------------------

      def method_missing(key, *args, &blk)
        key = key.to_s
        case key
        when /\?$/
          option(key.chomp('?'), *args, &blk)
        else
          #k = full_name ? "#{full_name} #{key}" : "#{key}"
          c = command(key, &blk)
          args.each{ |a| c[a] }
          c
        end
      end

      def help!(*args)
        Hash[*args].each do |key, desc|
          self[key, desc]
        end
      end

      # Define or retrieve a command.
      #
      #   subcommand('remote')
      #
      # A shortcut to accessing subcommands of subcommands, the following
      # statements are equivalent:
      #
      #   subcommand('remote').subcommand('add')
      #
      #   subcommand('remote add')
      #
      def subcommand(name, help=nil, &block)
        name, names = *name.to_s.strip.split(/\s+/)
        if names
          names = [name, *names]
          cmd = names.inject(self) do |c, n|
            c.subcommand(n)
          end
        else
          cmd = subcommands.find{ |c| c === name }
          unless cmd
            cmd = Command.new(name, self)
            subcommands << cmd
          end
        end
        cmd.help(help) if help
        cmd.instance_eval(&block) if block
        cmd
      end

      alias_method :cmd, :subcommand
      alias_method :command, :subcommand
      alias_method :commands, :subcommands

      # Define an option.
      #
      #   option(:output, :o)
      #
      def option(name, *aliases, &block)
        opt = options.find{|o| o === name}
        if not opt
          opt = Option.new(name, self)
          #opt.aliases(*aliases)
          @options << opt
        end
        opt.aliases(*aliases) unless aliases.empty?
        opt.instance_eval(&block) if block
        opt
      end

      alias_method :switch, :option

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

      alias_method :swt, :opt

      # A switch is like an option, but it is greedy.
      # When parsed it will pick-up any match subsequent
      # the switch's parent command. In other words,
      # switches are consumed by a command even if they
      # appear in a subcommand's arguments.
      #
      #def switch(name, *aliases, &block)
      #  if opt = @switches.find{|o| o === name}
      #  else
      #    opt = Option.new(name, self)
      #    opt.greedy = true
      #    opt.aliases(*aliases)
      #    @switches << opt
      #  end
      #  opt.instance_eval(&block) if block
      #  opt
      #end

      # Switch shorthand.
      #
      #   swt('--output=FILE -o', 'output directory')
      #
      #def swt(name, help=nil)
      #  name, *aliases = name.split(/\s+/)
      #  name, type = *name.split('=')
      #  mult = false
      #  if type && type[0,1] == '*'
      #    mult = true
      #    type = type[1..-1]
      #  end
      #  name = clean_name(name)
      #  o = switch(name, *aliases)
      #  o.help(help) if help
      #  o.argument(type) if type
      #  o.multiple(mult)
      #  self
      #end

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
      def argument(*n_type, &block)
        index = Integer===n_type[0] ? n_type.shift : @arguments.size + 1
        type  = n_type.shift
        help  = n_type.shift

        index = index - 1
        type = type.to_s.sub(/^\</,'').chomp('>')

        raise "Command cannot have both arguments (eg. #{type}) and subcommands." unless subcommands.empty?

        if arg = @arguments[index]
          arg.type(type) if type
          arg.help(help) if help
          arg.instance_eval(&block) if block
        else
          if type || block
            arg = Argument.new(type, self, &block)
            arg.help(help) if help
            @arguments[index] = arg
          end
        end
        return arg
      end

      alias_method :arg, :argument

      # Argument shorthand.
      #
      #   arg('PIN', 'pin number')
      #
      #def arg(type=nil, help=nil)
      #  type = type.to_s.sub(/^\</,'').chomp('>')
      #  argument(type).help(help)
      #  self
      #end

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
          subcommand(*x)
        end
      end

      # QUERY METHODS
      #-------------------------------------------------------------

      #
      def completion
        if subcommands.empty?
          arguments.collect{|c| c.key}
        else
          subcommands.collect{|c| c.name}
        end
      end

      # Option defined?
      #
      def option?(key)
        opt = options.find{|o| o === key}
        if parent && !opt
          opt = parent.option?(key)
        end
        opt
        #return opt if opt
        #options.each do |o|
        #  return o if o.aliases.include?(key)
        #end
        #nil
      end

      alias_method :switch?, :option

      # Greedy Option defined?
      #
      #def greedy_option?(key)
      #  switches.find{|o| o === key}
      #end

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
        #s << "@switches=#{@switches.inspect} "   unless @switches.empty?
        s << "@help=#{@help.inspect}"            unless @help.empty?
        #s << "@commands=#{@commands.inspect} "  unless @commands.empty?
        s
      end

      # Full callable command name.
      def full_name
        if parent && parent.full_name
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
          s << "[switches]"  # switches? vs. options
        end

        s << arguments.join(' ') unless arguments.empty?

        case subcommands.size
        when 0
        when 1
          s << subcommands.join('')
        when 2, 3
          s << '[' + subcommands.join(' | ') + ']'
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
        unless subcommands.empty?
          s << ''
          s << 'Commands:'
          s.concat(subcommands.collect{ |x| "  %-20s %s" % [x.key, x.help] }.sort)
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

