raise "DEFUNCT"

require 'clio/usage/subcommand'

module Clio

  module Usage #:nodoc:

    # = Command
    #
    # This is the toplevel "main" command.
    #
    # TODO: Subcommand is Command's superclass?
    #       Err... there's got to be a cleaner way.
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
      def help_text
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

    end#class

  end#module Usage

end#module Clio

