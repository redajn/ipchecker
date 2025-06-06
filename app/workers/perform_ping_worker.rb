require 'sidekiq'

class PerformPingWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default, retry: true

  def perform(ids)
    Pings::PerformService.new.call(ids)
  end
end
