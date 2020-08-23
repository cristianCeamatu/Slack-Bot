# frozen_string_literal: true

require 'rss'
require 'open-uri'
require_relative './stack_fetcher.rb'

module DriftingRuby
  module Commands
    class GetEpisode < SlackRubyBot::Commands::Base
      command 'get_posts' do |client, data, _match|
        variable = FetcherStackExchange.new('stackoverflow', 1)
        variable2 = variable.condition_checker('asc', 'ruby', 'what')
        variable3 = LinkChooser.new
        variable4 = variable3.link_chooser(variable2['items'])
        (0..9).each do |i|
          client.say(channel: data.channel, text: variable4[i])
        end
      end

      command 'say_hello' do |client, data, _match|
        client.say(channel: data.channel, text: HelloText.say_hello)
      end
    end
  end
end

class HelloText
  def self.say_hello
    'Hello! This is a Bot'
  end
end

class LinkChooser
  def link_chooser(object)
    array = []
    object.each_with_index do |_item, index|
      array.push(object[index]['link'])
    end
    array
  end
end
