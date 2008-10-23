require 'facets/kernel/deep_copy'
#require 'shellwords'
#require 'facets/kernel/object_class'
#require 'facets/array/indexable'

module Clio
  require 'clio/commandline'

  class Command

    class << self

      #
      def usage
        @usage ||= (
          if Command > ancestors[1]
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

  end # class Command

end # module Clio

