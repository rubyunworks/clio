require 'clio/commandline'

cli = Clio::Commandline.new

if cli.help?
  puts cli.to_s_help
  exit
end

if cli.hello!
  if cli.verbose? || cli.hello!.loud?
    puts "HELLO!"
  else
    puts "Hello!"
  end
end

