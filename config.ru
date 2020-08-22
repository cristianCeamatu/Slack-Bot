# require './bin/main'

# # Initialize the app and create the API (bot) object
# run Rack::Cascade.new [API]

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'dotenv'
Dotenv.load

require './lib/drifting_ruby.rb'

DriftingRuby::Bot.run
