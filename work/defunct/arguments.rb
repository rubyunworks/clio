
=begin
  # Parse out flags across the entire command line.
  # Flags parsed are the front flags and any specified in the
  # the +flags+ parameter. The +flags+ parameters can be either
  # a list of flag names or a name => arity hash.
  #
  # Returns the remaining split line and the global flags.

  def parse_global_flags( line=nil, flags={} )
    argv = parse_line(line)
    argv = multi_flag(argv)

    keys = []
    flags.each do |name, arity|
      while i = argv.index{ |e| e =~ /^-{1,2}#{name}/ }
        arg = argv[i]
        if arg.index('=')
          key, val = arg.split('=')
          keys << [name,val]
        elsif arity
          val = argv.slice!(i+1,arity)
          keys << [name,val]
        else
          keys << [name,true]
        end
        argv.delete(i)
      end
    end

    i = argv.index{ |e| e !~ /^-/ }
    glbl = argv[0...i]  # main options
    argv = argv[i..-1]  # rest of line

    glbl.each do |key|
      name = key.sub(/^-{1,2}/,'')
      keys.unshift [name, true]
    end

    keys = format_flags(keys)

    return argv, keys
  end


=end




  #   class MultiCommand < self
  # 
  #     # Multi-command.
  #     #
  #     # Parses a chain of commands from a single command line.
  #     # This assumes commands take no free standing arguments,
  #     # and rather only utilize option flags.
  #     #
  #     #   line = "--trace rubyforge --groupid=2014 publish --copy='**/*'
  #     #
  #     # This method does not support flag arity since each command in
  #     # the chain could have it's own arity settings. So '=' must be
  #     # used to set a flag parameter.
  # 
  #     def parse #( *opts_arity )
  #       #opts, arity  = clean(*opts_arity)
  # 
  #       pflags = preflags #(*opts_arity)
  # 
  #       args = argv.dup
  #       args = multi_flag(args) unless opts.include?(:simple)
  # 
  #       cmds = []
  # 
  #       f = args.find{ |e| e !~ /^-/ }
  #       i = f ? args.index(f) : -1
  #       until i < 0
  #         args = args[i..-1]  # chain command
  #         cmd = args.shift
  #         f = args.find{ |e| e !~ /^-/ }
  #         if f
  #           i = args.index(f)
  #           subopts = args[0...i]
  #         else
  #           i = -1
  #           subopts = args[0..-1]
  #         end
  #         keys = format_options(assoc_options(subopts)) #, *opts_arity))
  #         cmds << [cmd, keys]
  #       end
  # 
  #       return cmds, pflags
  #     end
  # 
  #   end
#   class TestArguments < Test::Unit::TestCase
#     include Console
# 
#     def test_multi_command
#       line = "-x baz --foo=6 bar --zoo='xx'"
#       cargs = Arguments::MultiCommand.new(line)
#       cmds, preflags = cargs.multi_command
# 
#       assert_equal({'x'=>true},preflags)
# 
#       cmd, keys = *cmds[0]
#       assert_equal('baz',cmd)
#       assert_equal({'foo'=>'6'},keys)
# 
#       cmd, keys = *cmds[1]
#       assert_equal('bar',cmd)
#       assert_equal({'zoo'=>'xx'},keys)
#     end




=begin
  # Subcommand.
  #
  # Subcommand parsing assumes that the first non-flag
  # entry is a subcommand, followed by subcommand flags.
  #

  def parse_subcommand( line=nil, arity={} )
    argv = parse_line(line)
    argv = multi_flag(argv)

    argv, glbl = parse_front_flags( argv, arity )

    cmd = argv.shift

    args, keys = parse_command(argv, arity)

    return cmd, args, keys, glbl
  end
=end

