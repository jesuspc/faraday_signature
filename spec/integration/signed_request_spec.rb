require 'spec_helper'
require 'faraday'
require 'json'

RSpec.describe 'Signed request', integration: true do
  before do
    Faraday::Request.register_middleware signature: Signatures::Faraday::Request::Signature
  end

  let(:key) { 'key' }
  let(:secret) { 'extremely_secret_stuff' }
  let(:timestamper) { double 'timestamper', call: timestamp }
  let(:timestamp) { 1 }
  let(:signature) { Signatures::Signers::Basic.new.call("param=1/potato-chimichanga#{timestamp}", secret: secret) }
  let(:params) { { param: 1 } }
  let(:stubs) do
    Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/potato-chimichanga') do |env|
        [200, {}, JSON.dump(env.request_headers)]
      end
    end
  end

  let(:conn) do
    Faraday.new(url: '/potato-chimichanga', params: params) do |faraday|
      faraday.request :signature, key: key, secret: secret, timestamper: timestamper
      faraday.adapter :test, stubs
    end
  end

  context 'with default config' do
    it 'adds the appropriate request headers' do
      resp = conn.get
      expect(JSON.parse resp.body).to include(
        "Timestamp" => timestamp,
        "Signature" => signature,
        "Signature_key" => key
      )
    end

    it 'adds a new timestamp' do
      allow(timestamper).to receive(:call) do
        rand(100000000)
      end
      first_res = conn.get
      second_res = conn.get

      first_timestamp = JSON.parse(first_res.body)['Timestamp']
      second_timestamp = JSON.parse(second_res.body)['Timestamp']
      expect(first_timestamp).not_to eq(second_timestamp)
    end
  end
end