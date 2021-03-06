module Clio

  class Usage #:nodoc:

    # = Commandline Option
    #
    class Option

      # Parent command.
      #attr :parent

      # Option name.
      attr :name

      # Alternate names for this option.
      attr :aliases

      # Option arguments.
      attr :arguments

      # Option can be used more that once.
      attr :multiple

      # Option (names) that are mutually exlusive
      # to this option.
      attr :excludes

      # Is the option greedy (true/false)? A greedy
      # option is one that is parsed from the
      # commandline no matter where it appears.
      #attr_accessor :greedy

      # Help text for this option.
      attr :desc

      # New Option.
      #def initialize(name, parent=nil, &block)
      def initialize(name, &block)
        @name      = clean_name(name)
        #@parent    = parent
        @aliases   = []
        @arguments = []
        @multiple  = false
        #@greedy    = false
        @exclude   = []
        @desc      = ''
        instance_eval(&block) if block
      end

      #
      def initialize_copy(o)
        @name    = o.name.dup
        @aliases = o.aliases.dup
        #@multiple = o.multiple
        @exclude = o.exclude.dup
        @desc    = o.desc.dup
      end

      # Same as +name+ but given as a symbol.
      def key
        name.to_sym
      end

      # Can this option occur multiple times in the
      # command line?
      def multiple? ; @multiple ; end

      # Is this option greedy?
      #def greedy?   ; @greedy   ; end

      #
      def inspect
        to_s
        #s  = "[--#{key}"
        #s << "*" if multiple
        #s << "=" + arguments.join(',') unless arguments.empty?
        #s << " " + aliases.collect{ |a| "-#{a}" } unless aliases.empty?
        ##s << " @excludes=#{@excludes.inspect}" unless @excludes.empty?
        #s << "]"
        #s
      end

      # Is this option a boolean flag?
      def flag?; @arguments.empty?; end

      # Assign an argument to the option.
      def argument(name, &block)
        arg = Argument.new(name) #, self)
        arg.instance_eval(&block) if block
        @arguments << arg
        arg
      end

      # Specify aliases for the option.
      def aliases(*names)
        return @aliases if names.empty?
        names.each do |name|
          @aliases << clean_key(name)
        end
      end

      # Specify if the option be used multiple times.
      def multiple(bool=nil)
        return @multiple if bool.nil?
        @multiple = bool
        self
      end

      # Specify mutually exclusive options.
      def xor(*opts)
        @exclusive.concat(opts)
      end

      #
      #def |(other)
      #  xor(other)
      #end

      #
      def desc(string=nil)
        @desc.replace(string.to_s) if string
        @desc
      end
      alias_method :description, :desc

      # Tab completion.
      def completion
        arguments.collect{|c| c.type}
      end

      # SHORTHAND NOTATION
      #-------------------------------------------------------------

      # Argument shorthand.
      #
      #   arg('PIN', 'pin number')
      #
      def arg(slot, desc=nil)
        argument(slot).desc(desc)
      end

      #
      def to_s
        tiny = aliases.select do |a|
          a.to_s.size == 1
        end
        tiny.unshift(name) if name.size == 1

        long = aliases.select do |a|
          a.to_s.size > 1
        end
        long.unshift(name) if name.size > 1

        tiny = tiny.collect{ |l| "-#{l}" }
        long = long.collect{ |w| "--#{w}" }

        if tiny.empty?
          opts = [ '  ', *long ]
        else
          opts = tiny + long
        end

        unless arguments.empty?
          args = arguments.collect{ |a| a.to_s.sub(/^[<]/,'').sub(/[>]$/,'') }
          opts.last << "=" + args.join(',')
        end

        opts.join(' ')
      end

      #
      def ===(other)
        other = clean_key(other)
        return true if clean_key(key) == other
        return true if aliases.include?(other)
        return false
      end

      # Breaks down an option at index of argv.
      #def parse(argv, index)
      #end

    private

      #
      def clean_key(key)
        clean_name(key).to_sym
      end

      #
      def clean_name(name)
        name = name.to_s
        name = name.gsub(/^[-]+/, '')
        name.chomp('?')
      end

      #
      def flag_key?(key)
        name = key.to_s
        return key[-1,1] == '?'
      end

      #
      def option_key(key)
        k = clean_key(key).to_s
        if k.size == 1
          "-#{k}".to_sym
        else
          "--#{k}".to_sym
        end
      end

    end

  end # class Commandline

end # module Clio

=begin
    # Option class. This is used by some command
    # of the command line parser class to store
    # option information.
    class Option
      attr_reader :name
      attr_accessor :type
      attr_accessor :init
      attr_accessor :desc

      alias_method :default, :init
      alias_method :description, :desc

      def initialize(name, desc, opts)
        @name = name
        @desc = desc
        @type = opts[:type] || 'value'
        @init = opts[:default] || opts[:init]
      end
      def usage
        "--#{name}=#{type.to_s.upcase}"
      end
      def assert_valid(value)
        raise "invalid" unless valid?(value)
      end
      def valid?(value)
        validation ? validation.call(value) : true
      end
      def validation(&block)
        @validation = block if block
        @validation
      end
    end
=end
