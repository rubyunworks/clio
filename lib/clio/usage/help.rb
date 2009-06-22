module Clio

  class Usage #:nodoc:

    class Help

      UPPER_SECTIONS = [ 'name', 'synopsis', 'description', 'options', 'commands', 'arguments' ]
      LOWER_SECTIONS = [ 'author', 'copyright' ]

      #
      def initialize() #usage)
        #@usage = usage

        @command_table   = {}
        @options_table   = {}
        @arguments_table = {}

        @sections = {}
      end

      # By setting the text attribute, you can fully override
      # the standard help output.
      def text=(txt)
        @override = txt.to_s
      end

      #
      def command_table(table=nil)
        if table
          @command_table = table
          @sections['commands'] = nil
        end
        @command_table
      end

      #
      def options_table(table=nil)
        if table
          @options_table = table
          @sections['options'] = nil
        end
        @options_table
      end
      alias_method :switch_table, :options_table

      #
      def argument_table(table=nil)
        if table
          @argument_table = table
          @sections['arguments'] = nil
        end
        @argument_table
      end

      #
      def synopsis(text=nil)
        @synopsis = text if text
        @synopsis
      end

      #
      def commands(text=nil)
        return @sections['commands'] = text if text
        @sections['commands'] ||= (
          s = @command_table.map do |(c, d)|
            "%-20s %s" % [c, d]
          end
          s.empty? ? nil : s.join("\n")
        )
      end

      #
      def options(text=nil)
        return @sections['options'] = text if text
        @sections['options'] ||= (
          s = @options_table.map do |(c, d)|
            "%-20s\n%s" % [c, d.sub(/^/, '    ')]
          end
          s.empty? ? nil : s.join("\n\n").rstrip
        )
      end

      #
      def arguments(text=nil)
        return @sections['arguments'] = text if text
        @sections['arguments'] ||= (
          s = @argument_table.map do |(c, d)|
            "%-20s %s" % [c, d]
          end
          s.empty? ? nil : s.join("\n")
        )
      end

      # Returns Manpage like help text. All sections of this
      # text can be replaced with manual entries.
      def to_s
        return @override if @override
        s = ''
        UPPER_SECTIONS.each do |title|
          body = send(title)
          s << title.upcase + "\n" + format(body) + "\n\n" if body
        end
        (@sections.keys - UPPER_SECTIONS - LOWER_SECTIONS).each do |title, body|
          body = send(title)
          s << title.upcase + "\n" + format(body) + "\n\n" if body
        end
        LOWER_SECTIONS.each do |title, body|
          body = send(title)
          s << title.upcase + "\n" + format(body) + "\n\n" if body
        end
        s 
      end

      # Returns very concise help text.
      def brief
        s = []
        s << "#{synopsis}"
        s << @options_table.map{ |(c, d)|
          "  %-20s %s" % [c, d]
        }.join("\n")
        s.join("\n")
      end

      #
      def format(text)
        text.gsub(/^/, "    ")
      end

      # If a section is not specifically defined, this will add it as a custom section.
      def method_missing(s, *a)
        if a.empty?
          return @sections[s.to_s.downcase]
        else
          @sections[s.to_s.downcase] = a.join
        end
      end

    end #class Help

  end #module Usage

end #module Clio

