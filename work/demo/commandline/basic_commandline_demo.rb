require 'clio/commandline'

cli = Clio::Commandline.new

cli.usage do
  command(:hello) do
    help('say hello')
    option(:loud) do
      help('say it loudly')
    end
  end
  option(:help, :h) do
    help('display help')
  end
  option(:verbose, :V) do
    help('verbose output')
  end
  option(:quiet, :q) do
    help('run silently')
    xor(:verbose)
  end
end

if cli.help?
  puts cli.to_s_help
  exit
end

if cli.hello!
  if cli.verbose? or cli.hello!.loud?
    puts "HELLO!"
  else
    puts "Hello!"
  end
end

