require 'shellwords'
require 'facets/kernel/object_class'

module Clio
  ### = Commandline
  ###
  ### What a strange thing is the Clio Commandline.
  ### An entity unknown until put upon. 
  class Commandline
    instance_methods.each{ |m| private m if m !~ /^(__|instance_|object_|send$|inspect$)/ }
  
    ### Splits a raw command line into two smaller
    ### ones. The first including only options
    ### upto the first non-option argument. This
    ### makes quick work of separating subcommands
    ### from a main command.
    # TODO: Rename this method.
    def self.gerrymander(argv=ARGV)
      if String===argv
        argv = Shellwords.shellwords(argv)
      end
      sub = argv.find{ |x| x !~ /^[-]/ }
      idx = argv.index(sub)
      opts = argv[0...idx]
      scmd = argv[idx..-1]
      return new(opts), new(scmd)
    end

    ### Define an option attibute.
    ### While commandline can be used without
    ### pre-declartion of support options
    ### doding so allows for creating option
    ### aliases. Eg. --quiet and -q.
    def self.attr(name, *aliases)
      name = name.to_s
      if name =~ /\?$/
        name = name.chomp('?')
        #attr_writer name
        module_eval "def #{name}?; self[:#{name}] ; end"
        aliases.each do |alt|
          alt = alt.to_s.chomp('?')
          alias_method("#{alt}?", "#{name}?")
          #alias_method("#{alt}=", "#{name}=")
        end
      else
        attr_reader(name)
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
    def self.runmodes
      index   = ancestors.index(::Clio::Commandline)
      options = ancestors[0...index].inject([]) do |opts, ancestor|
        opts | ancestor.instance_methods(false)
      end
      options.reject{ |o| o =~ /\=$/ }
      options.collect{ |o| o.to_sym }
    end

  public

    ### This method provides the centralized means of accessing
    ### the options and arguments of the commandline.
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
        index = index.to_s
        name  = index.chomp('?')
        key   = name.to_sym
        return @options[key] if @options.key?(key)

        @options[key] = if index =~ /\?$/
          name.size == 1 ? option_letter_flag(name)  : option_flag(name)
        else
          name.size == 1 ? option_letter_value(name) : option_value(name)
        end
      end
    end

    ### Access to the underlying commandline "ARGV".
    ### This will show what is yet to be processed.
    def instance_delegate ; @argv ; end

  private

    ### New Commandline. Takse a single argument
    ### which can be a "shell" string, or an array
    ### of shell arguments, like ARGV. If none
    ### is given it defaults to ARGV.
    def initialize(argv=ARGV)
      case argv
      when String
        @argv = Shellwords.shellwords(argv)
      else
        @argv = argv.dup
      end
      @arguments = []
      @options   = {}

      object_class.runmodes.each do |name|
        self[name]
      end
    end

    ###
    #def initialize(argv=ARGV)
    #  if Hash===argv
    #    argv.each{ |k,v| send("#{k}=", v) }
    #  else
    #    self.class.runmodes.each do |name|
    #      option(name)
    #    end
    #  end
    #end

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

    ### Helper method. This can be replaceb by
    ### String#index when it supports blocks.
    ### Err.. when will that be Matz?
    def index(array, &block)
      find = array.find(&block)
      array.index(find)
    end

    ### Parse a flag option.
    def option_flag(name)
p name
      o = "--#{name}"
      i = index(@argv){ |e| e =~ /^#{o}[=]?/ }
      return false unless i
      raise ArgumentError if @argv[i] =~ /=/
      @argv[i] = nil
      return true
    end

    ### Parse a value option.
    def option_value(name)
      o = "--#{name}"
      i = index(@argv){ |e| e =~ /^#{o}[=]?/ }
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
          @argv[i,2] = nil
        end
      end
      return val
    end

    ### Parse a single letter flag option.
    def option_letter_flag(letter)
      o = letter
      i = index(@argv){ |e| e =~ /[-]\w+(#{o})\w*$/ }
      if i
        @argv[i] = @argv[i].gsub(o,'')
        true
      end
      false
    end

    ### Parse a single letter value option.
    def option_letter_value(letter)
      o = letter
      i = index(@argv){ |e| e =~ /#{o}(\=|$)/ }
      return nil unless i
      if @argv[i] =~ /=/
        rest, val = argv[i].split('=')
        @argv[i] = rest
      else
        case @argv[i+1]
        when nil, /^-/
          raise ArgumentError
        else
          val = argv[i+1]
          @argv[i]   = argv[i].gsub(o,'')
          @argv[i+1] = nil
        end
      end
      return val    
    end

  end
end

