db_url =
  case ENV.fetch('RACK_ENV', 'development')
  when 'test'
    "#{ENV.fetch('DATABASE_URL')}_test"
  else
    ENV.fetch('DATABASE_URL')
  end

DB = Sequel.connect(db_url)
Sequel::Model.db = DB
