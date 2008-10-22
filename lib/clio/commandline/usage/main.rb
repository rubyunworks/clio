module Clio

  class Commandline
    require 'clio/commandline/usage/command'

    # = Usage
    #
    # Usage specifies the toplevel "Command".
    #
    class Main < Command

      # New Usage.
      #
      def initialize(name=nil, &block)
        name ||= File.basename($0)
        super(name, &block)
      end

      # Define a command.
      #
      #   command('remote')
      #   command('remote','add')
      #
      def command(*names, &block)
        names = names.collect{ |n| n.to_s.strip.to_sym }
        name, *names = *names
        cmd = @commands.find{|c| c === name}
        unless cmd
          cmd = super(name)
          #@commands << cmd
        end
        names.each do |n|
          cmd = cmd.command(n)
        end
        cmd.instance_eval(&block) if block
        cmd
      end

=begin
      #alias_method :[], :command


      # ARRAY NOTATION
      #-------------------------------------------------------------

      #
      def [](*args)
        res = nil
        head, *tail = *args
        case head.to_s
        when /^-/
          x = []
          opts = args.map do |o|
            o = o.to_s
            if i = o.index('=')
              x << o[i+1..-1]
              o[0...i]
            else
              o
            end
          end
          x = x.uniq

          res = opt(*opts)
        else
          args.each do |name|
            res = command(name)
          end
        end
        return res
      end
=end

      # Help text.
      #
      def to_s_help
        s = []
        s << "USAGE"
        s << "  " + to_s
        unless help.empty?
          s << help
          s << ''
        end
        unless commands.empty?
          s << ''
          s << 'COMMANDS'
          s.concat(commands.collect{ |x| "  %-20s %s" % [x.key, x.help] }.sort)
        end
        unless arguments.empty?
          s << ''
          s << "ARGUMENTS"
          s.concat(arguments.collect{ |x| "  %-20s %s" % [x, x.help] })
        end
        unless options.empty?
          s << ''
          s << 'OPTIONS'
          s.concat(options.collect{ |x| "  %-20s %s" % [[x.key, *x.aliases].join(' '), x.help] })
        end
        s.flatten.join("\n")
      end

      # Cache usage into a per-user cache file for reuse.
      # This can be used to greatly speed up tab completion.
      def cache
        File.open(cache_file, 'w'){ |f| f << to_yaml }
      end

    private

      # TODO: Use XDG
      
      def cache_file
        File.join(File.expand_path('~'), '.cache', 'clio', "#{name}.yaml")
      end

      def self.cache_file
        File.join(File.expand_path('~'), '.cache', 'clio', "#{name}.yaml")
      end

      def self.load_cache
        if File.file?(cache_file)
          YAML.load(File.new(cache_file))
        end
      end

    end #class Usage

  end #class Commandline

end #module Clio

