require 'clio/string'
require 'clio/layout/split'
require 'clio/layout/table'
require 'clio/layout/line'
require 'clio/layout/list'
require 'clio/layout/stack'
require 'clio/layout/flow'

module Clio

  def self.buffer
    Buffer.new
  end

  ###
  class Buffer

    def initialize()
      @buffer = []
    end

    def to_s
      @buffer.collect{|e| e.to_s}.join('')
    end

    def newline
      @buffer << "\n"
    end
    alias_method :nl, :newline

    def string(str)
      @buffer << String.new(str)
    end

    def line(fill='-')
      @buffer << Line.new(fill)
    end

    def split(left, rite)
      @buffer << Split.new(left, rite)
    end

    def table(*rows_of_cells)
      @buffer << Table.new(*rows_of_cells)
    end

    def list(*items)
      @buffer << List.new(*items)
    end

    #def columns(text, number=2)
    #end

    def stack(&block)
      
    end

    def flow
    end

    def print
      Kernel.print(to_s)
      @buffer = []
    end

    ###
    def method_missing(s, *a, &b)
      @buffer.last.send(s, *a, &b)
    end

  end

end





if $0 == __FILE__

  buf = Clio::Buffer.new
  buf.string("Hello").color(:red)
  buf.string("World").color(:green)
  buf.justify.print


  h = Clio.string("Hello").color(:red)
  w = Clio.string("World").color(:green)

  (h | w).print

end

