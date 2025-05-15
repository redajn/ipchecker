module Ips
  class IdContract < BaseContract
    params { required(:id).filled(Types::Params::Integer.constrained(gt: 0)) }
  end
end
