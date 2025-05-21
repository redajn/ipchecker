if ENV['RACK_ENV'] == 'test'
  ENV['DATABASE_URL'] = "postgres://#{ENV['DB_USER']}:#{ENV['DB_PASSWORD']}@#{ENV['DB_HOST']}:5432/ipchecker_db_test"
end

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))
Sequel::Model.db = DB
