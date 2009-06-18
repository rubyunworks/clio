require 'clio/consoleutils'

ask("How now?") do |a|
  raise AnswerRetry unless a == 'q'
end

