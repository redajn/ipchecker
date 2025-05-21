Sequel.migration do
  up do
    run <<~SQL
      CREATE TABLE IF NOT EXISTS pings (
        id SERIAL NOT NULL,
        ip_id INTEGER NOT NULL REFERENCES ips(id) ON DELETE CASCADE,
        rtt FLOAT,
        success BOOLEAN NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id, created_at)
      ) PARTITION BY RANGE (created_at);
    SQL

    today = Date.today
    this_monday = today - ((today.wday + 6) % 7)
    next_monday = this_monday + 7
    init_partition = "pings_#{this_monday.strftime('%Y%m%d')}_#{next_monday.strftime('%Y%m%d')}"

    run <<~SQL
      CREATE TABLE IF NOT EXISTS #{init_partition} PARTITION OF pings
      FOR VALUES FROM ('#{this_monday}') TO ('#{next_monday}');
    SQL

    run <<~SQL
      CREATE INDEX IF NOT EXISTS idx_pings_on_ip_created_at
      ON pings (ip_id, created_at);
    SQL
  end

  down do
    run 'DROP TABLE IF EXISTS pings CASCADE;'
  end
end
