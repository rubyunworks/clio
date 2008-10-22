module Clio

  class Commandline

    # = Commandline Option
    #
    class Option

      # Parent command.
      attr :parent

      #
      attr :key

      # 
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
      attr_accessor :greedy

      # Help text for this option.
      attr :help

      #
      def initialize(key, parent=nil, &block)
        @key       = clean_key(key)
        @parent    = parent
        @aliases   = []
        @arguments = []
        @multiple  = false
        @greedy    = false
        @excludes  = []
        @help      = ''
        instance_eval(&block) if block
      end

      def name
        @name ||= clean_key(key).to_s
      end

      #
      def multiple? ; @multiple ; end

      #
      def greedy?   ; @greedy   ; end

      #
      def inspect
        s  = "[--#{key}"
        s << "*" if multiple
        s << arguments.join(',') unless arguments.empty?
        s << aliases.join(' ') unless aliases.empty?
        #s << " @excludes=#{@excludes.inspect}" unless @excludes.empty?
        s << "]"
        s
      end

      def flag?; @arguments.empty?; end

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
          @aliases << clean_key(name)
        end
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
      #def |(other)
      #  self.xor(other)
      #end

      #
      def help(string=nil)
        @help.replace(string.to_s) if string
        @help
      end

      # Tab completion.
      def completion
        arguments.collect{|c| c.key}
      end

      # SHORTHAND NOTATION
      #-------------------------------------------------------------

      # Argument shorthand.
      #
      #   arg('PIN', 'pin number')
      #
      def arg(slot, help=nil)
        argument(slot).help(help)
      end

      #
      def to_s
        s = []
        s << (name.size == 1 ? "-#{name}" : "--#{name}")
        @aliases.each do |a|
          s << (a.to_s.size == 1 ? "-#{a}" : "--#{a}")
        end
        s.join(' ')
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
        key = key.to_s
        key = key.gsub(/^[-]+/, '')
        key.chomp('?').to_sym
      end

      #
      def clean_name(key)
        clean_key(key).to_s
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
