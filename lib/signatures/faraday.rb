require 'signatures/faraday/version'
require 'signatures/faraday/request'

module Signatures
  module Faraday
    def self.try
      require 'faraday'
      Faraday::Request.register_middleware signature: FaradaySignature::Request::Signature

      conn = Faraday.new(:url => 'http://localhost:3000') do |faraday|
        faraday.request :signature
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end
  end
end