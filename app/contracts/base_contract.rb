require 'dry-validation'
require 'dry/types'
require 'ipaddr'

class BaseContract < Dry::Validation::Contract
  Types = Dry.Types()
end
