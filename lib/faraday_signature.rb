require 'faraday_signature/version'
require 'faraday_signature/request'
require 'faraday_signature/signer'

module FaradaySignature
  def self.try
    require 'faraday'
    Faraday::Request.register_middleware :request, signature: FaradaySignature::Request::Signature

    conn = Faraday.new(:url => 'http://google.com') do |faraday|
      faraday.request :signature
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end
end
