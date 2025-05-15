module Ips
  class StatsContract < BaseContract
    params do
      required(:id).filled(Types::Params::Integer.constrained(gt: 0))
      required(:from).filled(Types::Params::String)
      required(:to).filled(Types::Params::String)
    end

    rule(:from, :to) do
      from_t = Time.iso8601(values[:from])
      to_t   = Time.iso8601(values[:to])
      key(:to).failure('must be after from') if to_t <= from_t
    rescue ArgumentError
      key.failure('invalid ISO8601')
    end
  end
end
