module FaradaySignature
  module Request
    class Signature
      module SignableExtractor
        def self.call(request, signable_elms)
          signable_elms.map do |elm|
            extractor_for(elm).call request
          end
        end

        def self.extractor_for(elm)
          extractors[elm]
        end

        def self.extractors
          @extractors ||= {
            params: Params,
            body: Body
          }
        end

        Params = ->(request) { request.params }
        # TODO: Support multipart requests
        Body = lambda do |request|
          request.body.rewind
          body_content = request.body.read
          begin
            JSON.parse body_content
          rescue JSON::ParseError
            {}
          end
        end
      end
    end
  end
end
