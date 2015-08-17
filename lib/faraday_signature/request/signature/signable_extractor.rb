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

        Params = lambda do |request|
          request.url.query
        end
        # TODO: Support multipart requests by not signing them
        Body = lambda do |request|
          if request.body
            request.body.rewind
            request.body.read
          end
        end
      end
    end
  end
end
