# frozen_string_literal: true

require 'sinatra/base'
require 'net/http'
require_relative './bot.rb'

# This is a class
class API < Sinatra::Base
  # Send response of message to response_url
  def self.send_response(response_url, msg)
    url = URI.parse(response_url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request['content-type'] = 'application/json'
    request.body = JSON[msg]
    http.request(request)
  end

  post '/slack/events' do
    request_data = JSON.parse(request.body.read)
    case request_data['type']
    when 'url_verification'
      # URL Verification event with challenge parameter
      request_data['challenge']
    when 'event_callback'
      # Verify requests
      return if request_data['token'] != ENV['SLACK_TOKEN']

      event_data = request_data['event']
      case event_data['type']
        # Message IM event
      when 'message'
        return if event_data['subtype'] == 'bot_message' || event_data['subtype'] == 'message_changed'

        Bot.handle_direct_message(event_data) if event_data['user']
      else
        puts "Unexpected events\n"
      end
      status 200
    end
  end

  post '/slack/command' do
    request_data = JSON.parse(request.body.read)
    status 200 if request_data['command'] == '/surf'
  end

  post '/slack/attachments' do # rubocop:todo Metrics/BlockLength
    request.body.rewind
    request_data = request.body.read
    # Convert
    request_data = URI.decode_www_form_component(request_data, Encoding::UTF_8)
    # Parse and remove "payload=" from beginning of string
    request_data = JSON.parse(request_data.sub!('payload=', ''))
    url = request_data['response_url']
    user_id = request_data['user']['id']
    msg = request_data['original_message']
    case request_data['callback_id']
      # Start game callback
    when 'play:start'
      msg['text'] = ':video_game: OK I\'m starting the game.'
      msg['attachments'] = []
      API.send_response(url, msg)
      Bot.start_game(user_id)
      msg = Bot.show_board(user_id)
      API.send_response(url, msg)
      # Select position callback
    when 'play:select_position'
      loop do
        chosen = request_data['actions'][0]['value'].to_i
        if chosen.zero?
          msg = Bot.show_board(user_id)
          API.send_response(url, msg)
          break
        end
        Bot.update_board(user_id, chosen, 'X')
        break if Bot.check_winner_draw(user_id, url, msg)

        msg['text'] = ' It is my turn.'
        msg['attachments'] = Bot.board_last(user_id)
        API.send_response(url, msg)
        sleep(1)
        chosen = Bot.choose_position(user_id)
        msg['text'] = "I\'m chosing #{chosen}."
        API.send_response(url, msg)
        Bot.update_board(user_id, chosen, 'O')
        sleep(1)
        break if Bot.check_winner_draw(user_id, url, msg)

        msg = Bot.show_board(user_id)
        API.send_response(url, msg)
        break
      end
      # Play finish callback
    when 'play:finish'
      msg['text'] = ':ok: If you want to play more, I will be here. Only send any message to me '
      msg['attachments'] = []
      API.send_response(url, msg)
      client = Slack::Web::Client.new
      client.conversations_close(user: user_id)
    end
    status 200
  end
end
