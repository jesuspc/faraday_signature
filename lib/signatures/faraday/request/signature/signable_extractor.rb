module Signatures
  module Faraday
    module Request
      class Signature
        module SignableExtractor
          def self.call(request, signable_elms, opts = {})
            signable_elms.map do |elm|
              extractor_for(elm).call request, opts
            end
          end

          def self.extractor_for(elm)
            extractors[elm]
          end

          def self.extractors
            @extractors ||= {
              params: Params,
              body: Body,
              path: Path,
              timestamp: Timestamp
            }
          end

          Path = lambda do |request, _|
            request.url.path
          end

          Params = lambda do |request, _|
            request.url.query
          end
          # TODO: Support multipart requests by not signing them
          Body = lambda do |request, _|
            request.body unless request.body.nil?
          end

          Timestamp = lambda do |_, opts = {}|
            opts[:timestamp]
          end
        end
      end
    end
  end
end
