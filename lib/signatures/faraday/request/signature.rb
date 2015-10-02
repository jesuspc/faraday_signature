require 'signatures/faraday/request/signature/signable_extractor'
require 'signatures/timestampers/basic'
require 'signatures/signers/basic'

require 'cgi'

module Signatures
  module Faraday
    module Request
      class Signature
        TIMESTAMP_HEADER = 'Timestamp'.freeze
        SIGNATURE_HEADER = 'Signature'.freeze
        SIGNATURE_KEY_HEADER = 'Signature_key'.freeze

        attr_accessor :app, :options, :timestamper, :secret, :key,
                      :signer, :signable_extractor, :signable_elms

        def initialize(app, options = {})
          options = symbolize_keys(options)

          self.app = app
          self.options = options
          self.secret = options[:secret]
          self.key = options[:key]

          self.signable_elms = Array(options[:signable] || [:params, :body, :timestamp])
          self.signable_extractor = options[:signable_extractor] || SignableExtractor
          self.signer = options.fetch :signer, Signatures::Signers::Basic.new
          self.timestamper = options.fetch :timestamper, Signatures::Timestampers::Basic
        end

        def call(env)
          env[:request_headers][TIMESTAMP_HEADER] = timestamp if timestamper
          env[:request_headers][SIGNATURE_HEADER] = build_signature(env)
          env[:request_headers][SIGNATURE_KEY_HEADER] = key.to_s
          app.call env
        end

        private

        def symbolize_keys(hash)
          hash.each_with_object({}) do |(k,v), memo|
            memo[k.to_sym] = v
          end
        end

        def build_signature(request)
          signer.call signable(request), secret: secret
        end

        def timestamp
          @timestamp ||= timestamper.call
        end

        def signable(request)
          signable_extractor.call request, signable_elms, timestamp: timestamp
        end

        attr_writer :app, :options, :timestamper, :secret, :key,
                    :signer, :signable_extractor, :signable_elms
      end
    end
  end
end
