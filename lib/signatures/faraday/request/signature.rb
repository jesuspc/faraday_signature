require 'signatures/faraday/request/signature/signable_extractor'
require 'signatures/timestampers/basic'
require 'signatures/signers/basic'

require 'cgi'
require 'naught'

module Signatures
  module Faraday
    module Request
      class Signature
        TIMESTAMP_HEADER = 'Timestamp'.freeze
        SIGNATURE_HEADER = 'Signature'.freeze
        SIGNATURE_KEY_HEADER = 'Signature_key'.freeze

        attr_accessor :app, :options, :timestamper, :secret, :key,
                      :signer, :signable_extractor, :signable_elms,
                      :logger

        def initialize(app, options = {})
          options = symbolize_keys(options)

          self.app = app
          self.options = options
          self.secret = options[:secret]
          self.key = options[:key]
          self.logger = options[:logger] || fake_logger

          self.signable_elms = Array(options[:signable] || [:params, :body, :path, :timestamp])
          self.signable_extractor = options[:signable_extractor] || SignableExtractor
          self.signer = options.fetch :signer, Signatures::Signers::Basic.new
          self.timestamper = options.fetch :timestamper, Signatures::Timestampers::Basic
        end

        def call(env)
          env[:request_headers][TIMESTAMP_HEADER] = timestamp if timestamper
          env[:request_headers][SIGNATURE_HEADER] = build_signature(env)
          env[:request_headers][SIGNATURE_KEY_HEADER] = key.to_s
          logger.info do
            "[#{Time.now.utc.iso8601}][#{self.class}] Signing Request with Timestamp: "\
            "#{env[:request_headers][TIMESTAMP_HEADER]} - Signature: #{env[:request_headers][SIGNATURE_HEADER]}"\
            " - Key: #{env[:request_headers][SIGNATURE_KEY_HEADER]}"
          end
          app.call env
        end

        private

        def fake_logger
          Naught.build { |config| config.black_hole }.new
        end

        def symbolize_keys(hash)
          hash.each_with_object({}) do |(k,v), memo|
            memo[k.to_sym] = v
          end
        end

        def build_signature(request)
          payload = signable(request)
          signer.call(payload, secret: secret).tap do |signature|
            logger.info { "[#{Time.now.utc.iso8601}][#{self.class}] Signed payload: #{payload} - Signature: #{signature}" }
          end
        end

        def timestamp
          @timestamp ||= timestamper.call
        end

        def signable(request)
          signable_extractor.call request, signable_elms, timestamp: timestamp
        end

        attr_writer :app, :options, :timestamper, :secret, :key,
                    :signer, :signable_extractor, :signable_elms,
                    :logger
      end
    end
  end
end
