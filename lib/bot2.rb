module DriftingRuby
  class Bot < SlackRubyBot::Bot
    help do
      title 'Drifting Ruby Bot'
      desc 'This is about StackOverFlow'

      command :get_posts do
        title 'get_posts'
        desc 'Returns the url of the stack posts'
        long_desc 'Return the url of the 10 stack posts'
      end
    end
  end
end