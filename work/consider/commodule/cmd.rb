#$commands = Hash.new{|h,k| h[k]={} }

def execute
  obj = self
  cmd = :main
  opts = []
  ARGV.each_with_index do |arg, i|
    case arg
    when /^-/
      opts << arg.sub(/^-{1,2}/,'')
    else
      com = Clio::Commodule::Com.new(obj, opts, true)
      obj = obj.send(cmd, com)
      opts = []
      if obj.class.commands.key?(arg.to_sym)
        cmd = arg
      else
        raise "error #{arg} for #{obj}"
      end
    end
  end
  com = Clio::Commodule::Com.new(obj, opts, false)
  obj.send(cmd, com)
end

module Clio

  #= Commodule
  module Commodule

    def commands
      @commands ||= {}
    end

    def help(help)
      @pending ||= {}
      @pending[:help] = help
    end

    def opt(name, help)
      @pending ||= {}
      @pending[:options] ||= {}
      @pending[:options][name.to_sym] = help
    end

    def arg(name, help)
      @pending ||= {}
      @pending[:arguments] ||= {}
      @pending[:arguments][name.to_sym] = help
    end

    def method_added(name)
      if @pending
        cmd = Command.new(@pending)
        commands[name.to_sym] = cmd
        #$commands[self][name.to_sym] = cmd
        @pending = nil
      end
      super
    end

    class Command
      def initialize(ioc)
        @arguments = ioc[:arguments]
        @options = ioc[:options]
        @help = ioc[:help]
      end
    end

    # = Com
    class Com
      attr :parents
      attr :options
      def initialize(parent, options, continues)
        @parent  = parent
        @options = options
        @continues = continues
      end
      def continues?
        @continues
      end
    end

  end

end#module Clio




if $0 == __FILE__

  class Example1

    extend Clio::Commodule

    help "start something wonderful"

    opt :verbose, "detailed output"

    arg :files, "glob of files"

    def doc(com)
      p com #.args
      #p com.opts
      Example2.new(com) #.args, com.opts)
    end

  end

  class Example2

    extend Clio::Commodule

    def initialize(com)
      @last = com
    end

    help "finish something wonderful"

    opt :verbose, "detailed output"

    arg :files, "glob of files"

    def all(com)
      #p com #.args
      p com.options
      puts "HERE!"
    end

  end

  #p Example.commands

  #p $commands

  def main(com)
    p com
    Example1.new
  end

  execute

end