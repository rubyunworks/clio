module Clio

  class Stack < Layout

    def initialize(&block)
      instance_eval(&block)
    end

  end

end

