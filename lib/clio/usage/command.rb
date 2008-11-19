require 'clio/usage/subcommand'

module Clio

  module Usage #:nodoc:

    # = Command
    #
    # This is the toplevel "main" command.
    #
    class Command < Subcommand

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
      #def command(name, &block)
      #  raise "Command cannot have both arguments and subcommands (eg. #{name})." unless arguments.empty?
      #  key = name.to_s.strip
      #  if cmd = @commands.find{|c| c === key}
      #  else
      #    cmd = Command.new(key, self)
      #    @commands << cmd
      #  end
      #  cmd.instance_eval(&block) if block
      #  cmd
      #end

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

=begin
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
          s << "[switches]"
        end
# switches? vs. options
        s << arguments.join(' ') unless arguments.empty?

        case commands.size
        when 0
        when 1
          s << commands.join('')
        when 2, 3
          s << '[' + commands.join(' | ') + ']'
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
        unless commands.empty?
          s << ''
          s << 'Commands:'
          s.concat(commands.collect{ |x| "  %-20s %s" % [x.key, x.help] }.sort)
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
=end

      def parse(argv)
        Parser.new(self, argv).parse #(argv)
      end

      # Cache usage into a per-user cache file for reuse.
      # This can be used to greatly speed up tab completion.
      #
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

    end#class Main

  end#module Usage

end#module Clio

