require 'faraday_signature/request/signature/signable_extractor'
require 'faraday_signature/timestamper'
require 'faraday_signature/signer'

require 'rack/request'

module FaradaySignature
  module Request
    class Signature
      def initialize(app, options = {}, &_)
        @app = app
        @options = options

        @signable_elms = Array(options[:signable]) || default_signable_elms
        @signable_extractor = options[:signable_extractor] || SignableExtractor
        @signer = options[:signer] || Signer
        @timestamper = options.fetch :timestamper, Timestamper
      end

      def call(env)
        #request = Rack::Request.new(env)
        #request.update_param :timestamp, build_timestamp if timestamper
        #request.update_param :signature, build_signature(request)
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

      def default_signable_params
        [:params, :body]
      end

      attr_reader :app, :options, :signer, :timestamper, :signable_elms
    end
  end
end
