module Clio

  # Option class. This is used by some command
  # of the command line parser class to store
  # option information.
  class Option
    attr_reader :name
    attr_accessor :type
    attr_accessor :init
    attr_accessor :desc

    alias_method :default, :init
    alias_method :description, :desc

    def initialize(name, desc, opts)
      @name = name
      @desc = desc
      @type = opts[:type] || 'value'
      @init = opts[:default] || opts[:init]
    end
    def usage
      "--#{name}=#{type.to_s.upcase}"
    end
    def assert_valid(value)
      raise "invalid" unless valid?(value)
    end
    def valid?(value)
      validation ? validation.call(value) : true
    end
    def validation(&block)
      @validation = block if block
      @validation
    end
  end

end
