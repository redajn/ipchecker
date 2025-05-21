require 'sidekiq'
require_relative 'perform_ping_worker'

class EnqueuePingPerformingWorker
  include Sidekiq::Worker

  BATCH_SIZE = 100

  def perform
    ids = Ip.where(enabled: true).select_map(:id)

    ids.each_slice(BATCH_SIZE) do |batch|
      PerformPingWorker.perform_async(batch)
    end
  end
end
