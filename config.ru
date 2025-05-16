ENV['RACK_ENV'] ||= 'development'
require_relative 'config/environment'

require 'sidekiq/web'

if ENV['RACK_ENV'] == 'development'
  require 'rack/unreloader'
  Unreloader = Rack::Unreloader.new(subclasses: %w[Sinatra Sequel::Model]) { App }
  Unreloader.require './app'

  run Unreloader
else
  run App
end
