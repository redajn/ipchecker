class CreateNextWeekPartitionWorker
  include Sidekiq::Worker

  def perform
    today = Date.today
    days_until_next_monday = (8 - today.wday) % 7
    days_until_next_monday = 7 if days_until_next_monday.zero?
    start_date = today + days_until_next_monday
    end_date = start_date + 7
    partition_name = "pings_#{start_date.strftime('%Y%m%d')}_#{end_date.strftime('%Y%m%d')}"

    DB.run <<~SQL
      CREATE TABLE IF NOT EXISTS #{partition_name}
      PARTITION OF pings
      FOR VALUES FROM ('#{start_date}') TO ('#{end_date}');
    SQL
  end
end
