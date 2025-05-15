require 'spec_helper'

RSpec.describe Ips::CreateService do
  subject(:service) { described_class.new }

  context 'with valid params' do
    let(:params) { { 'ip' => '8.8.8.8', 'enabled' => 'true' } }

    it 'creates a new Ip and returns Success' do
      result = service.call(params)
      expect(result).to be_success
      ip = result.value!
      expect(ip[:ip]).to eq '8.8.8.8'
      expect(ip[:enabled]).to be true
    end
  end

  context 'with invalid ip' do
    let(:params) { { 'ip' => 'not-an-ip' } }

    it 'returns Failure with validation errors' do
      result = service.call(params)
      expect(result).to be_failure
      expect(result.failure[:code]).to eq :validation
      expect(result.failure[:errors]).to include(ip: ['Invalid IP address format'])
    end
  end

  context 'when ip already exists' do
    before { Ip.create(ip: '1.1.1.1', enabled: true) }
    let(:params) { { 'ip' => '1.1.1.1' } }

    it 'returns Failure code :already_exists' do
      result = service.call(params)
      expect(result).to be_failure
      expect(result.failure[:code]).to eq :already_exists
    end
  end
end
