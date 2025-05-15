require_relative 'switch_service'

module Ips
  class EnableService < SwitchService
    def call(input)
      super(input, flag: true)
    end
  end
end
