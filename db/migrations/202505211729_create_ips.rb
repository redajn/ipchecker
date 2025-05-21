Sequel.migration do
  up do
    run <<~SQL
      CREATE TABLE IF NOT EXISTS ips (
        id SERIAL PRIMARY KEY,
        ip VARCHAR NOT NULL,
        enabled BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    SQL

    run <<~SQL
      CREATE INDEX IF NOT EXISTS idx_ips_enabled_true_id
      ON ips (id)
      WHERE enabled = TRUE;
    SQL
  end

  down do
    run 'DROP TABLE IF EXISTS ips CASCADE;'
  end
end
