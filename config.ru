ENV['RACK_ENV'] ||= 'development'

if ENV['RACK_ENV'] == 'development'
  require_relative 'config/environment'
  require 'rack/unreloader'
  Unreloader = Rack::Unreloader.new(subclasses: %w[Sinatra Sequel::Model]) { App }
  Unreloader.require './app'

  run Unreloader
else
  run App
end

Thread.new do
  loop do
    puts 'ping jod was started!'
    PingJob.run
    sleep 60 # sec
  end
end
