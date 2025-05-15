class Ping < Sequel::Model
  many_to_one :ip
end
