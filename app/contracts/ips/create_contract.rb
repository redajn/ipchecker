module Ips
  class CreateContract < BaseContract
    params do
      required(:ip).filled(Types::Params::String)
      optional(:enabled).value(Types::Params::Bool.default(false))
    end

    rule(:ip) do
      IPAddr.new(value)
    rescue IPAddr::InvalidAddressError, IPAddr::AddressFamilyError
      key.failure('Invalid IP address format')
    end
  end
end
