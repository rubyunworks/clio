require 'clio/usage/main'
require 'clio/usage/parser'

module Clio

  # = Usage
  #
  #  usage = Clio::Usage.new
  #  usage.command('show')
  #  usage.command('hide')
  #  cli = usage.parse
  #
  module Usage

    def self.new(name=nil, &block)
      Main.new(name, &block)
    end

  end#module Usage

end#module Clio

