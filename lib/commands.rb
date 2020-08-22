require 'rss'
require 'open-uri'
require_relative './stack_fetcher.rb'

module DriftingRuby
  module Commands
    class GetEpisode < SlackRubyBot::Commands::Base
      command 'get_latest_episode' do |client, data, _match|
        variable = FetcherStackExchange.new('stackoverflow', 1)
        variable2 = variable.condition_checker('asc', 'ruby', 'what')
        variable4 = link_chooser(variable2['items'])
        for i in 0..9 do
          client.say(channel: data.channel, text: variable4[i])
        end
      end

      command 'say_hello' do |client, data, _match|
        client.say(chanlel: data.channel, text: HelloText.say_hello)
      end
    end
  end
end

class HelloText
  def self.say_hello
    'Hello! This is a Bot'
  end
end


def link_chooser(object)
  array = []
  object.each_with_index do |_item, index|
    array.push(object[index]['link'])
  end
  array
end

