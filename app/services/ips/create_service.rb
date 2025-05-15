module Ips
  class CreateService < BaseService
    Contract = Ips::CreateContract.new

    def call(input)
      data = yield validate(input, Contract)
      yield check_uniqueness(data[:ip])
      record = yield persist(data)

      Success(serialize(record))
    end

    private

    def check_uniqueness(ip)
      return Failure(code: :already_exists) if Ip.first(ip: ip)

      Success()
    end

    def persist(data)
      record = Ip.create(**data)

      Success(record)
    rescue Sequel::Error => e
      Failure(code: :db_error, message: e.message)
    end
  end
end
