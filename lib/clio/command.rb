require 'facets/kernel/deep_copy'
require 'clio/usage'

module Clio

  class Command

    class << self

      # Command usage.
      def usage
        @usage ||= (
          if ancestors[1] < Command
            @usage = ancestors[1].usage.deep_copy
          else
            @usage = Usage.new
          end
        )
      end

      #
      def command(*names, &block)
        usage.command(*names, &block)
      end

      #
      def option(name, *aliases, &block)
        usage.option(name, *aliases, &block)
      end

      #
      def argument(name, &block)
        usage.argument(name, &block)
      end

      #
      def help(string=nil)
        usage.help(string)
      end

      #
      def cmd(label, help, &block)
        usage.cmd(label, help, &block)
      end

      #
      def opt(label, help, &block)
        usage.opt(label, help, &block)
      end

      #
      def swt(label, help, &block)
        usage.swt(label, help, &block)
      end

      #
      def arg(label, help, &block)
        usage.arg(label, help, &block)
      end

    end

    # New Command.
    def initialize(argv=nil, opts={}, &block)
      argv_set(argv || ARGV)
      #if opts[:usage]
      #  @usage = opts[:usage]
      #else
      #  #@usage = load_cache
      #end
      (class << self; self; end).usage(&block) if block
    end

    #
    def argv_set(argv)
      # reset parser
      @parser = nil
      # convert to array if string
      if String===argv
        argv = Shellwords.shellwords(argv)
      end
      # remove anything subsequent to '--'
      if index = argv.index('--')
        argv = argv[0...index]
      end
      @argv = argv
    end

    #
    #def usage(name=nil, &block)
    #  @usage ||= Usage.new(name)
    #  @usage.instance_eval(&block) if block
    #  @usage
    #end

    def usage
      (class << self; self; end).usage
    end

    #
    def to_s
      usage.to_s
    end

    #
    def to_s_help
      usage.to_s_help
    end

    #
    def parse(argv=nil)
      argv_set(argv) if argv
      @cli = parser.parse
    end

    #
    def parser
      @parser ||= Usage::Parser.new(usage, @argv)
    end

    #
    def [](i)
      @cli[i]
    end

    #
    def command    ; @cli.command    ; end

    #
    def commands   ; @cli.commands   ; end

    #
    def arguments  ; @cli.arguments  ; end

    #
    def switches   ; @cli.options    ; end

    #
    alias_method :options, :switches

    # Parameters
    #
    def parameters ; @cli.parameters ; end

    #
    def to_a
      @cli.to_a
    end

    # Commandline fully valid?
    #
    def valid?
      @cli.valid?
    end

    # TODO: adding '-' is best idea?
    #
    def completion(argv=nil)
      argv_set(argv) if argv
      @argv << '-'
      parse
      @argv.pop
      parser.errors[0][1].completion.collect{ |s| s.to_s }
      #@argv.pop if @argv.last == '?'
      #load_cache
      #parse
    end

    #
    #def load_cache
    #  if usage = Usage.load_cache
    #    @usage = usage
    #  end
    #end

  end # class Command

end # module Clio


=begin
    #
    def initialize(argv=nil, &block)
      @cli = Commandline.new(argv, :usage=>self.class.usage, &block)
    end

    def parse     ; @cli.parse     ; end

    #
    def usage     ; @cli.usage     ; end

    #
    def command   ; @cli.command   ; end

    #
    def commands  ; @cli.commands  ; end

    #
    def options   ; @cli.options   ; end

    #
    def arguments ; @cli.arguments ; end

    #
    def [](i)     ; @cli[i]        ; end

    #
    def method_missing(s, *a, &b)
      @cli.send(s, *a, &b)
    end
=end

