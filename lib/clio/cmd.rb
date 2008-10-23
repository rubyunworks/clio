


    #
    instance_methods.each do |m|
      private m if m !~ /^(__|instance_|object_|send$|class$|inspect$|respond_to\?$)/
    end


    # Method missing provide passive usage and parsing.
    #
    # TODO: This reparses the commandline after every usage
    #       change. Is there a way to do partial parsing instead?
    def method_missing(s, *a)
      begin
        s = s.to_s
        case s
        when /[=]$/
          n = s.chomp('=')
          usage.option(n).type(*a)
          #parser.parse
          res = parser.options[n.to_sym]
        when /[!]$/
          n = s.chomp('!')
          cmd = usage.commands[n.to_sym] || usage.command(n, *a)
          res = parser.parse
        when /[?]$/
          n = s.chomp('?')
          u = usage.option(n, *a)
          res = parser.options[u.key]
        else
          usage.option(s, *a)
          #parser.parse
          res = parser.options[s.to_sym]
        end
      rescue Usage::ParseError => e
        res = nil
      end
      return res
    end


