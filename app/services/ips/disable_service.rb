require_relative 'switch_service'

module Ips
  class DisableService < SwitchService
    def call(input)
      super(input, flag: false)
    end
  end
end
