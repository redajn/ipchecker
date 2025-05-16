require "sequel"
require_relative '../config/database'

DB.create_table?(:ips) do
  primary_key :id
  String :ip, null: false
  TrueClass :enabled, default: false
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
end

DB.create_table?(:pings) do
  primary_key :id
  foreign_key :ip_id, :ips, on_delete: :cascade
  Float :rtt  # ms
  TrueClass :success, null: false
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
end


DB.add_index :ips, [:id], name: :idx_ips_enabled_true_id, where: { enabled: true }, if_not_exists: true
DB.add_index :pings, [:ip_id, :created_at], name: :idx_pings_on_ip_created_at, if_not_exists: true
