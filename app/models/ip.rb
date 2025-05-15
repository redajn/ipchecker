class Ip < Sequel::Model
  one_to_many :pings
end
