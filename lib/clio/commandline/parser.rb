module Clio

  class Commandline

    ### = Commandline Parser
    ### This class parses a command line.
    class Parser

      instance_methods.each{ |m| private m if m !~ /^(__|instance_|object_|send$|inspect$|respond_to\?$)/ }

      ### Splits a raw command line into two smaller
      ### ones. The first including only options
      ### upto the first non-option argument. This
      ### makes quick work of separating a subcommand
      ### from the options for a main command.
      # TODO: Rename this method.
      #def self.gerrymander(argv=ARGV)
      #  if String===argv
      #    argv = Shellwords.shellwords(argv)
      #  end
      #  sub = argv.find{ |x| x !~ /^[-]/ }
      #  idx = argv.index(sub)
      #  opts = argv[0...idx]
      #  scmd = argv[idx..-1]
      #  return opts, scmd
      #end

    private

      ### New Commandline. Takes a single argument
      ### which can be a "shell" string, or an array
      ### of shell arguments, like ARGV. If none
      ### is given it defaults to ARGV.
      def initialize(usage, argv=nil)
        @usage = usage

        argv ||= ARGV
        case argv
        when String
          @argv = Shellwords.shellwords(argv)
        #when Hash
        #  argv.each{ |k,v| send("#{k}=", v) }
        else
          @argv = argv.dup
        end

        @arguments = []

        # parse predefined options attributes.
        #object_class.predefined_options.each do |modes|
        #  key = modes.first.to_s.chomp('?')
        #  modes.reverse.each do |i|
        #    val = option_parse(i)
        #    instance_variable_set("@#{key}", val) if val
        #  end
        #end
      end

      ### Routes to #option!.
      def method_missing(name, *args)
        case name.to_s
        when /\=$/
          super
        else
          option!(name, *args)
        end
      end

    public

      ### This method provides the centralized means 
      ### of accessing the options and arguments on
      ### the commandline.
      def [](index)
        case index
        when Integer
          @arguments[index] ||= (
            args = @argv.select{ |e| e !~ /^-/ }
            val = args[index]
            #@argv.delete(args[index]) # WRONG!!!! b/c index will keep changing.
            val
          )
        else
          option!(index)
        end
      end

      def option!(name, *aliases)
        return send(name) if respond_to?(name)
        key = name.to_s.chomp('?')
        val = option_parse(name)
        instance_variable_set("@#{key}", val)
        (class << self; self; end).class_eval %{
           def #{name}; @#{key}; end
        }
        return val
      end

      def shift!
        args = @argv.select{ |e| e !~ /^-/ }
        val = args.first
        @argv.delete(val)
        val
      end

      ### Define an option alias. This adds an entry to 
      ### the aliases hash, pointing +new+ to a list of
      ### all aliases and the first entry on the list
      ### being the master key.
      def option_alias(new, old)
        option!(old)
        key = old.to_s.chomp('?')
        val = option_parse(new)
        instance_variable_set("@#{key}", val) if val
        (class << self; self; end).class_eval do
          alias_method new, old
        end
      end

      ### Access to the underlying commandline "ARGV".
      ### This will show what is yet to be processed.
      def instance_delegate ; @argv ; end

      ### Returns a hash of all options parsed.
      def instance_options
        h = {}
        ivs = instance_variables - ['@arguments','@argv']
        ivs.each do |iv|
          val = instance_variable_get(iv)
          h[iv.sub('@','').to_sym] = val if val
        end
        h
      end

      ### Returns a list of all arguments parsed.
      def instance_arguments
        @arguments
      end

      ### Parse an option.
      def option_parse(index)
        index = index.to_s
        name  = index.chomp('?')
        key   = name.to_sym

        kind = name.size == 1 ? 'letter' : 'word'
        flag = index =~ /\?$/ ? 'flag'   : 'value'

        send("option_#{kind}_#{flag}", key)
      end

      ### Parse a flag option.
      def option_word_flag(name)
        o = "--#{name}"
        i = @argv.index_of{ |e| e =~ /^#{o}[=]?/ }
        return false unless i
        raise ArgumentError if @argv[i] =~ /=/
        @argv.delete_at(i)
        return true
      end

      ### Parse a value option.
      def option_word_value(name)
        o = "--#{name}"
        i = @argv.index_of{ |e| e =~ /^#{o}[=]?/ }
        return false unless i

        if @argv[i] =~ /=/
          key, val = *@argv[i].split('=')
          argv[i] = nil
        else
          case @argv[i+1]
          when nil, /^-/
            raise ArgumentError
          else
            key = @argv[i]
            val = @argv[i+1]
            @argv.delete_at(i) # do it twice
            @argv.delete_at(i)
          end
        end
        return val
      end

      ### Parse a single letter flag option.
      def option_letter_flag(letter)
        o = letter
        i = @argv.index_of{ |e| e =~ /[-][^-]\w*(#{o})\w*$/ }
        if i
          @argv[i] = @argv[i].gsub(o.to_s,'')
          true
        end
        false
      end

      ### Parse a single letter value option.
      def option_letter_value(letter)
        o = letter
        i = @argv.index_of{ |e| e =~ /[-]\w*#{o}(\=|$)/ }
        return nil unless i
        if @argv[i] =~ /=/
          rest, val = argv[i].split('=')
          @argv[i] = rest
        else
          case @argv[i+1]
          when nil, /^-/
            raise ArgumentError
          else
            val = @argv[i+1]
            new = @argv[i].gsub(o.to_s,'')
            if new == '-'
              @argv.delete_at(i)
            else
              @argv[i] = new
            end
            @argv.delete_at(i+1)
          end
        end
        return val    
      end

    end

  end

end

