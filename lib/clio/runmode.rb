warn "deprecated by commandline"
exit 0

require 'clio/commandline'

module Clio

  # = Runmode
  #
  class Runmode

    ###
    def self.attr(name, *aliases)
      name = name.to_s
      if name =~ /\?$/
        name = name.chomp('?')
        attr_writer name
        module_eval do
          "def #{name}?; @#{name} ; end"
        end
        aliases.each do |alt|
          alt = alt.to_s.chomp('?')
          alias_method("#{alt}?", "#{name}?")
          alias_method("#{alt}=", "#{name}=")
        end
      else
        attr_accessor name
        aliases.each do |alt|
          alt = alt.to_s.chomp('?')
          alias_method("#{alt}" , "#{name}")
          alias_method("#{alt}=", "#{name}=")
        end
      end
    end

    #
    def self.runmodes
      i = ancestors.index(::Clio::Runmode)
      m = ancestors[0...i].inject([]) do |modes, ancestor|
        modes | ancestor.instance_methods(false)
      end
      modes.reject{ |mode| mode =~ /\=$/ }
    end

    ###
    def initialize(argv=ARGV)
      if Hash===argv
        argv.each{ |k,v| send("#{k}=", v) }
      else
        cmd = Commandline.new(argv)
        self.class.runmodes.each do |mode|
          key = mode.chomp('?')
          val = cmd.send(mode)
          send("#{key}=", val) if val
        end
        @runmode_commandline = cmd
      end

      ###
      def runmode_commandline
        @runmode_commandline
      end

      ###
      def runmode_leftover
        runmode_commandline.instance_delegate
      end
    end


=begin
    #
    def runmode_parse(argv)
      opts = {}
      runmodes.each do |mode|
        if mode =~ /\?$/
          # If a simple letter flag
          if mode.to_s.size == 1
            if argv.delete("-#{mode}")
              opts[mode] = true
            else
              if fs = argv.select{ |a| a =~ /^\-\w+#{mode}\w*$/ }
                opts[mode] = true unless fs.empty?
                fs.each{ |a| a.gsub!(mode, '') }
              end
            end
          else
            opts[mode] = true if argv.delete("--#{mode}")
          end
        else

        end
      end
      new(opts)
    end
=end

  end

  ### = Runmode::Standard
  # Convenience class for the most common modes.
  # This class encapsulates common global options for
  # command line scripts. The built-in modes are:
  #
  #   force
  #   trace
  #   debug
  #   dryrun -or- noharm -or- pretend ?
  #   silent -or- quiet
  #   verbose
  #
  class Runmode::Standard < Runmode
    attr :force?
    attr :debug?
    attr :trace?

    # TODO: Reduce to one, two at most.
    attr :noharm, :dryrun, :pretend, :n

    attr :quiet? :q?

    attr :verbose?, :v?  #:V ? :loud ?
  end

end

