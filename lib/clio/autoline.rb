require 'clio/commandline'

module Clio

  # = AutoCommandline
  #
  # Clio's AutoCommandline is a subclass of Commandline.
  # It can be used lazily, whereby information about usage
  # is built-up as the Commandline object gets use in
  # one's program.
  #
  # See Commandline for underlying implementation.
  #
  # == Passive Parsing
  #
  # The AutoCommandline class allows you to declare as little or as
  # much of the commandline interface upfront as is suitable to
  # your application. When using an AutoCommandline object, if not
  # already defined, options will be lazily created. For example:
  #
  #   cli = Clio::AutoCommandline.new('--force')
  #   cli.force?  #=> true
  #
  # Commandline sees that you expect a '--force' flag to be an
  # acceptable option becuase you asked for it with #force?.
  # So it will call cli.usage.option('force') behind the scenes
  # before trying to determine the actual value per the content
  # of the command line. You can add aliases as parameters to
  # this call as well.
  #
  #   cli = Clio::AutoCommandline.new('-f')
  #   cli.force?(:f)  #=> true
  #
  # Once set, you do not need to specify the alias again:
  #
  #   cli.force?      #=> true
  #
  # With the exception of help information, this means you can
  # generally just use a commandline as needed without having
  # to declare anything upfront, which can be very useful for
  # simple commandline parsing usecases.
  #

  class AutoCommandline < Commandline

    CPM = Commandline.public_instance_methods(false).map{ |m| m.to_sym }

    #
    instance_methods.each do |m|
      private m unless m =~ /^(__|instance_|object_|send$|class$|inspect$|respond_to\?$)/ || CPM.include?(m.to_s) || CPM.include?(m.to_sym)
    end

    # Method missing provide passive usage and parsing.
    #
    # TODO: This reparses the commandline after every query.
    #       Really only need to parse if usage has change.
    #
    def method_missing(s, *a)
      begin
        s = s.to_s
        case s
        when /[=]$/
          n = s.chomp('=')
          usage.option(n).type(*a)
          parse(@argv)
          res = @cli.options[n.to_sym]
        #when /[!]$/
        #  n = s.chomp('!')
        #  cmd = usage.command(n, *a) #||usage.commands[n.to_sym] ||  
        #  res = parse(@argv)
        when /[?]$/
          n = s.chomp('?')
          u = usage.option(n, *a)
          parse(@argv)
          res = @cli.options[u.key]
        else
          n = s.chomp('!')
          cmd = usage.command(n, *a) #||usage.commands[n.to_sym] ||  
          res = parse(@argv)
          #usage.option(s, *a)
          #parse
          #res = @cli.options[s.to_sym]
        end
      rescue Usage::ParseError => e
        res = nil
      end
      return res
    end

  end # class AutoCommandline

end # module Clio

