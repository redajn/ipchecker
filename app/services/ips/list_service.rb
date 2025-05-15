module Ips
  class ListService < BaseService
    def call
      records = Ip.order_by(:id).all

      return Failure(code: :not_found) if records.empty?

      result = records.map { |ip| serialize(ip) }
      Success(result)
    end
  end
end
