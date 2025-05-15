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
