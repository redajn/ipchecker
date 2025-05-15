require 'spec_helper'

RSpec.describe Ips::DeleteService do
  subject(:service) { described_class.new }

  let!(:ip) { Ip.create(ip: '8.8.4.4', enabled: true) }

  it 'deletes an existing ip' do
    result = service.call(id: ip.id)
    expect(result).to be_success
    expect(Ip[ip.id]).to be_nil
  end

  it 'returns not_found for missing id' do
    result = service.call(id: 9999)
    expect(result).to be_failure
    expect(result.failure[:code]).to eq :not_found
  end
end
