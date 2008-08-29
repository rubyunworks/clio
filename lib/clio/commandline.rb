require 'shellwords'
require 'facets/kernel/object_class'
require 'facets/array/index'

module Clio
  ### = Commandline
  ###
  ### What a strange thing is the Clio Commandline.
  ### An entity unknown until put upon.
  ###
  ###   cmd = Clio::Commandline.new("--force copy --file try.rb")
  ###   cmd.option_alias(:f?, :force?)
  ###   cmd.option_alias(:o, :file)
  ###
  ###   cmd.file   #=> 'try.rb'
  ###   cmd.force? #=> true
  ###   cmd.o      #=> 'try.rb'
  ###   cmd.f?     #=> true
  ###
  ### TODO: Allow option setter methods (?)
  ### TODO: Allow a hash as argument to initialize (?)
  class Commandline
    instance_methods.each{ |m| private m if m !~ /^(__|instance_|object_|send$|inspect$)/ }

    ### Splits a raw command line into two smaller
    ### ones. The first including only options
    ### upto the first non-option argument. This
    ### makes quick work of separating a subcommand
    ### from the options for a main command.
    # TODO: Rename this method.
    def self.gerrymander(argv=ARGV)
      if String===argv
        argv = Shellwords.shellwords(argv)
      end
      sub = argv.find{ |x| x !~ /^[-]/ }
      idx = argv.index(sub)
      opts = argv[0...idx]
      scmd = argv[idx..-1]
      return opts, scmd
    end

    ### Define an option attibute.
    ### While commandline can be used without
    ### pre-declartion of support options
    ### doding so allows for creating option
    ### aliases. Eg. --quiet and -q.
    def self.attr(name, *aliases)
      (@predefined_options ||= []) << [name, *aliases]

      name = name.to_s
      if name =~ /\?$/
        key = name.chomp('?')
        #attr_writer name
        module_eval "def #{key}?; @#{key} ; end"
        aliases.each do |alt|
          alt = alt.to_s.chomp('?')
          alias_method("#{alt}?", "#{key}?")
          #alias_method("#{alt}=", "#{name}=")
        end
      else
        attr_reader name
        #module_eval "def #{name}; self[:#{name}] ; end"
        aliases.each do |alt|
          #alt = alt.to_s.chomp('?')  # TODO: raise error ?
          alias_method("#{alt}" , "#{name}")
          #alias_method("#{alt}=", "#{name}=")
        end
      end
    end

    ### Returns a list of all pre-defined options.
    ### It does this by seaching class ancestry
    ### for instance_methods until it reaches the
    ### Commandline base class.
    ### TODO: Rename #runmodes method.
    ### TODO: Robust enough? Use an Inheritor instead?
    def self.predefined_options
      @predefined_options ||= []
      ancestor = ancestors[1]
      if ancestor > ::Clio::Commandline
        @predefined_options
      else
        @predefined_options | ancestor.predefined_options
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
          @argv.delete(args[index])
          val
        )
      else
        return send(index) if respond_to?(index)
        key = index.to_s.chomp('?')
        val = option_parse(index)
        instance_variable_set("@#{key}", val)
        (class << self; self; end).class_eval %{
           def #{index}; @#{key}; end
        }
        return val
      end
    end

    def shift!
      args = @argv.select{ |e| e !~ /^-/ }
      val = args.first
      @argv.delete(val)
      val
    end

    ### Define an option alias. This adds en entry to 
    ### the aliases hash, pointing new to a list of
    ### all aliases and the first entry on th list
    ### being the master key.
    def option_alias(new, old)
      self[old]
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

  private

    ### New Commandline. Takse a single argument
    ### which can be a "shell" string, or an array
    ### of shell arguments, like ARGV. If none
    ### is given it defaults to ARGV.
    def initialize(argv=ARGV)
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
      object_class.predefined_options.each do |modes|
        key = modes.first.to_s.chomp('?')
        modes.reverse.each do |i|
          val = option_parse(i)
          instance_variable_set("@#{key}", val) if val
        end
      end
    end

    ### Routes to #[].
    def method_missing(name, *args)
      super unless args.empty?
      case name.to_s
      when /\=$/
        super
      else
        self[name]
      end
    end

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
      i = @argv.index{ |e| e =~ /^#{o}[=]?/ }
      return false unless i
      raise ArgumentError if @argv[i] =~ /=/
      @argv.delete_at(i)
      return true
    end

    ### Parse a value option.
    def option_word_value(name)
      o = "--#{name}"
      i = @argv.index{ |e| e =~ /^#{o}[=]?/ }
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
      i = @argv.index{ |e| e =~ /[-][^-]\w*(#{o})\w*$/ }
      if i
        @argv[i] = @argv[i].gsub(o.to_s,'')
        true
      end
      false
    end

    ### Parse a single letter value option.
    def option_letter_value(letter)
      o = letter
      i = @argv.index{ |e| e =~ /[-]\w*#{o}(\=|$)/ }
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

