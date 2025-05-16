require 'sidekiq'
require_relative 'ping_worker'

class EnqueuePingWorker
  include Sidekiq::Worker

  BATCH_SIZE = 100

  def perform
    ids = Ip.where(enabled: true).select_map(:id)

    ids.each_slice(BATCH_SIZE) do |batch|
      PingWorker.perform_async(batch)
    end
  end
end
