require 'spec_helper'

RSpec.describe 'IPs API', type: :request do
  let(:json_body) { JSON.parse(last_response.body) }

  describe 'POST /ips' do
    context 'with valid parameters' do
      it 'creates a new IP and returns 201' do
        post '/ips', ip: '8.8.8.8'
        expect(last_response.status).to eq(201)
        expect(json_body).to include('id', 'ip' => '8.8.8.8', 'enabled' => false)
      end
    end

    context 'with invalid IP' do
      it 'returns 422 and error message' do
        post '/ips', ip: 'not-an-ip'
        expect(last_response.status).to eq(422)
        expect(json_body['code']).to eq('validation')
        expect(json_body['errors']).to have_key('ip')
      end
    end

    context 'when IP already exists' do
      before { Ip.create(ip: '1.1.1.1', enabled: true) }

      it 'returns 409 conflict' do
        post '/ips', ip: '1.1.1.1'
        expect(last_response.status).to eq(409)
        expect(json_body['code']).to eq('already_exists')
      end
    end
  end

  describe 'GET /ips' do
    before do
      Ip.create(ip: '9.9.9.9', enabled: true)
      Ip.create(ip: '8.8.4.4', enabled: false)
    end

    it 'returns list of all IPs with 200' do
      get '/ips'
      expect(last_response.status).to eq(200)
      expect(json_body).to be_an(Array)
      expect(json_body.map { |h| h['ip'] }).to contain_exactly('9.9.9.9', '8.8.4.4')
    end
  end

  describe 'POST /ips/:id/enable' do
    let!(:ip) { Ip.create(ip: '8.8.8.8', enabled: false) }

    it 'enables the IP and returns 200' do
      get "/ips/#{ip.id}/enable"
      expect(last_response.status).to eq(200)
      expect(json_body).to include('enabled' => true)
      expect(Ip[ip.id].enabled).to be true
    end

    it 'returns 404 for non-existent id' do
      get '/ips/9999/enable'
      expect(last_response.status).to eq(404)
      expect(json_body['code']).to eq('not_found')
    end
  end

  describe 'POST /ips/:id/disable' do
    let!(:ip) { Ip.create(ip: '8.8.4.4', enabled: true) }

    it 'disables the IP and returns 200' do
      get "/ips/#{ip.id}/disable"
      expect(last_response.status).to eq(200)
      expect(json_body).to include('enabled' => false)
      expect(Ip[ip.id].enabled).to be false
    end
  end

  describe 'GET /ips/:id/stats' do
    let!(:ip) { Ip.create(ip: '1.2.3.4', enabled: true) }
    before do
      Ping.create(ip_id: ip.id, rtt: 50.0, success: true,  created_at: Time.now - 60)
      Ping.create(ip_id: ip.id, rtt: 70.0, success: true,  created_at: Time.now - 30)
      Ping.create(ip_id: ip.id, rtt: nil,  success: false, created_at: Time.now - 10)
    end

    it 'returns aggregated stats for given interval' do
      from = (Time.now - 120).iso8601
      to   = Time.now.iso8601
      get "/ips/#{ip.id}/stats", from: from, to: to
      expect(last_response.status).to eq(200)
      expect(json_body).to include(
        'min_rtt' => 50.0,
        'max_rtt' => 70.0,
        'avg_rtt' => 60.0,
        'median_rtt' => 60.0,
        'stddev_rtt' => be > 0.0,
        'loss_percent' => be_within(0.1).of(33.33)
      )
    end

    it 'returns 422 for bad date format' do
      get "/ips/#{ip.id}/stats", from: 'bad', to: 'dates'
      expect(last_response.status).to eq(422)
    end
  end

  describe 'DELETE /ips/:id' do
    let!(:ip) { Ip.create(ip: '4.4.4.4', enabled: true) }

    it 'deletes the IP and returns 204' do
      delete "/ips/#{ip.id}"
      expect(last_response.status).to eq(204)
      expect(Ip[ip.id]).to be_nil
    end

    it 'returns 404 for already deleted id' do
      delete "/ips/#{ip.id}"
      delete "/ips/#{ip.id}"
      expect(last_response.status).to eq(404)
      expect(json_body['code']).to eq('not_found')
    end
  end
end
