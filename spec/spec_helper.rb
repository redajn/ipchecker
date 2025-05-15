ENV['RACK_ENV'] = 'test'
require 'pry'
require 'rack/test'
require 'database_cleaner-sequel'
require_relative '../config/environment'
require_relative '../app/app'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:suite) do
    DatabaseCleaner[:sequel].db = DB
    DatabaseCleaner[:sequel].strategy = :transaction
    DatabaseCleaner[:sequel].clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner[:sequel].cleaning do
      example.run
    end
  end

  def app
    App
  end
end
