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
    class Subcommand

      # Parent command. This is needed
      # to support cascading options.
      #--
      # NOTE: If it were possible to have this it would be better.
      #++
      attr :parent

      # Name of the command.
      attr :name

      # Array of subcommands.
      attr :subcommands

      # Array of arguments. Arguments and subcommands
      # are mutually exclusive, ie. either @arguments
      # or @subcommands will be empty.
      #
      # TODO: Could use single attribute for both subcommands
      # and arguments and use a flag to designate which type.
      attr :arguments

      # Array of options.
      attr :options

      # Help text.
      attr :help

      # Widely accepted alternate term for options.
      alias_method :switches, :options

      #
      def initialize(name, parent=nil, &block)
        @name        = name.to_s
        @parent      = parent
        @subcommands = []
        @options     = []
        @arguments   = []
        @help        = ''
        instance_eval(&block) if block
      end

      #
      def initialize_copy(c)
        @parent      = c.parent
        @name        = c.name.dup
        @options     = c.options.dup
        @arguments   = c.arguments.dup
        @subcommands = c.subcommands.dup
        @help        = c.help.dup
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

      # Define or retrieve a subcommand.
      #
      #   subcommand('remote')
      #
      # As a shortcut to accessing subcommands of subcommands, the
      # following statements are equivalent:
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
            cmd = Subcommand.new(name, self)
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
          opt = Option.new(name) #, self)
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
        name = option_name(name).to_sym
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

        if type[0,1] == '*'
          type.sub!('*', '')
          splat = true
        elsif type[-1,1] == '*'
          type.sub!(/[*]$/, '')
          splat = true
        else
          splat = false
        end

        #if type.index(':')
        #  name, type = *type.split(':')
        #  name = name.downcase
        #  type = type.upcase
        #else
        #  if type.upcase == type
        #    name = nil
        #  else
        #    name = type
        #    type = type.upcase
        #  end
        #end

        unless subcommands.empty?
          raise ArgumentError, "Command cannot have both arguments (eg. #{type}) and subcommands."
        end

        if arg = @arguments[index]
          arg.type(type) if type
          #arg.name(name) if name
          arg.help(help) if help
          arg.splat(splat) if splat
          arg.instance_eval(&block) if block
        else
          if type || block
            arg = Argument.new(type, &block) #self, &block)
            #arg.name(name) if name
            arg.help(help) if help
            arg.splat(splat) if splat
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

      # Access help description(s) for this command.
      #
      # If no argument is given, return this command's
      # help description.
      #
      # If a single argument is given, this sets the
      # description for this command.
      #
      # If multiple arguments are given, there should
      # be an even number; the pairs of which set the
      # help descriptions for subelements. See #help!
      #
      def help(*string)
        case string.size
        when 0
          @help
        when 1
          @help.replace(string.to_s)
          @help
        else
          help!(*string)
        end
      end

      # Set the help descriptions for subelements.
      # There should be an even number or argument, or
      # a Hash should be passed. 
      #
      #   help!( "document" , "generate documents",
      #          "--verbose", "do it loudly" )
      #
      def help!(*args)
        Hash[*args.to_a.flatten].each do |key, desc|
          self[key, desc]
        end
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
          options.collect{|o| o.to_s.strip } +
          arguments.collect{|c| c.name}
        else
          options.collect{|o| o.to_s.strip } +
          subcommands.collect{|c| c.name}
        end
      end

      # Option defined?
      #
      def option?(name)
        opt = options.find{|o| o === name}
        if parent && !opt
          opt = parent.option?(name)
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
        s << "#<#{self.class}:#{object_id} #{@name}"
        s << " @arguments=#{@arguments.inspect} " unless @arguments.empty?
        s << " @options=#{@options.inspect} "     unless @options.empty?
        s << " @help=#{@help.inspect}"            unless @help.empty?
        #s << "@commands=#{@commands.inspect} "  unless @commands.empty?
        s << ">"
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
      # TODO: Could help_text be called #to_str?
      #
      def helptext
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
          s.concat(subcommands.collect{ |x| "  %-20s %s" % [x.name, x.help] }.sort)
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

      #def option_key(key)
      #  name = option_name(key) #.to_s
      #  if name.size == 1
      #    "-#{name}".to_sym
      #  else
      #    "--#{name}".to_sym
      #  end
      #end

      def option_name(name)
        name = name.to_s
        name = name.gsub(/^[-]+/, '')
        return name.chomp('?') #.to_sym
      end

    end #class Command

  end #module Usage

end #module Clio

