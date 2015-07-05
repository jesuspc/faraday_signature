require 'openssl'

module FaradaySignature
  module Signer
    module_function

    def configure
      yield self
    end

    def call(to_sign, options = {})
      text_to_sign = String to_sign.reduce(&:merge)
      secret = options[:secret] || self.secret

      hmac.hexdigest sha1, secret, text_to_sign
    end

    # TODO: improve those getter-setters. As they are now those methods have
    # two different responsabilities.
    def secret(val = nil)
      @secret = val if val
      @secret ||= 'not_secret_at_all'
    end

    def hmac(val = nil)
      @hmac = val if val
      @hmac ||= OpenSSL::HMAC
    end

    def sha1(val = nil)
      @sha1 = val if val
      @sha1 ||= OpenSSL::Digest::SHA1.new
    end
  end
end
