module Ips
  class DeleteService < BaseService
    Contract = Ips::IdContract.new

    def call(input)
      data   = yield validate(input, Contract)
      record = yield fetch(data[:id])
      yield destroy(record)

      Success(nil)
    end

    private

    def fetch(id)
      ip = Ip[id]
      ip ? Success(ip) : Failure(code: :not_found)
    end

    def destroy(record)
      record.delete
      Success()
    rescue Sequel::Error => e
      Failure(code: :db_error, message: e.message)
    end
  end
end
