require 'sidekiq'
require 'sidekiq-cron'
require_relative '../config/environment'

puts 'Sidekiq is starting...'
Sidekiq.configure_server do |config|
  config.on(:startup) do
    schedule = YAML.load_file(File.expand_path('sidekiq.yml', __dir__))[:cron]
    Sidekiq::Cron::Job.load_from_hash(schedule)
  end
end
