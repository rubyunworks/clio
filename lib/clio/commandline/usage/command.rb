module Clio

  class Commandline
    require 'clio/commandline/usage'

    # = Commandline Command
    #
    # Commands cannot have both arguments and subcommands. While it is technically
    # parsable (an older version of Commandline allowed it), when using a command
    # it proves too easy to accidently omit an argument and have a subcommand take
    # its place, causing erroneous behavior. I looked through a number of other
    # commandline tools and never once found a case of subcommands following arguments,
    # so it was decided to purposely limit Commandline in this fashion.
    #
    class Command
      attr :parent

      attr :name

      attr :commands
      attr :options
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

      def key
        @name
      end

=begin
      def inspect
        s  = "#{@key}"
        s << " #{@options.inspect}" unless @options.empty?
        s << " #{@commands.inspect}" unless @commands.empty?
        s << " #{@arguments.inspect}" unless @arguments.empty?
        s << ""
        s
      end
=end

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
          index = n2 || (@arguments.size + 1)
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

      #
      def completion
        if commands.empty?
          arguments.collect{|c| c.key}
        else
          commands.collect{|c| c.name}
        end
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
      # or
      #
      #   arg(1, 'PIN', 'pin number')
      #
      def arg(slot, type=nil, help=nil)
        argument(slot, type).help(help)
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
      def ===(other)
        name == other.to_s
      end

      # Usage text.
      #
      def to_s
        s = [name]
        #@aliases.each do |a|
        #  s << a #.key
        #end
        s.concat(options.collect{ |o| "[#{o}]" })
        s << arguments.join(' ') unless arguments.empty?
        case commands.size
        when 0
        when 1
          s << commands.join('')
        when 2, 3
          s << '[' + commands.join(' | ') + ']'
        else
          s << 'COMMAND'
        end
        s.flatten.join(' ')
      end

      #---------------------------------

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

    end

  end #class Commandline

end #module Clio

