require 'signatures/faraday/request/signature/signable_extractor'
require 'signatures/faraday/timestamper'
require 'signatures/faraday/signer'

require 'cgi'

module FaradaySignature
  module Request
    class Signature
      TIMESTAMP_HEADER = 'Timestamp'.freeze
      SIGNATURE_HEADER = 'Signature'.freeze

      def initialize(app, options = {}, &_)
        @app = app
        @options = options

        @signable_elms = Array(options[:signable] || default_signable_elms)
        @signable_extractor = options[:signable_extractor] || SignableExtractor
        @signer = options.fetch(:signer)
        @timestamper = options.fetch :timestamper, Timestamper
      end

      def call(env)
        env[:request_headers][TIMESTAMP_HEADER] = build_timestamp if timestamper
        env[:request_headers][SIGNATURE_HEADER] = build_signature(env)
        app.call env
      end

      private

      def build_signature(request)
        signer.call signable(request)
      end

      def build_timestamp
        timestamper.call
      end

      def signable(request)
        signable_extractor.call request, signable_elms
      end

      def default_signable_elms
        [:params, :body]
      end

      attr_reader :app, :options, :timestamper,
                  :signer, :signable_extractor, :signable_elms
    end
  end
end
