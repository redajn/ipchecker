require 'dry/monads'
require 'dry/monads/do'

class BaseService
  include Dry::Monads[:result, :do]

  def serialize(ip)
    { id: ip.id, ip: ip.ip, enabled: ip.enabled }
  end

  def validate(input, contract)
    result = contract.call(input)
    return Failure(code: :validation, errors: result.errors.to_h) unless result.success?

    Success(result.to_h)
  end
end
