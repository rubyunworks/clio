module Clio

  class NoOptionError < ::NoMethodError # ArgumentError ?
    def initialize(name, *arg)
      super("unknown option -- #{name}", name, *args)
    end
  end

  class NoCommandError < ::NoMethodError
    def initialize(name, *arg)
      super("unknown subcommand -- #{name}", name, *args)
    end
  end

end

