module Ips
  class SwitchService < BaseService
    Contract = Ips::IdContract.new

    def call(input, flag:)
      data   = yield validate(input, Contract)
      record = yield find_ip(data[:id])
      record = yield switch(record, flag)

      Success(serialize(record))
    end

    private

    def find_ip(id)
      ip = Ip[id]
      ip ? Success(ip) : Failure(code: :not_found)
    end

    def switch(record, flag)
      record.update(enabled: flag)
      Success(record)
    rescue Sequel::Error => e
      Failure(code: :db_error, message: e.message)
    end
  end
end
