require 'openssl'

module FaradaySignature
  module Signer
    module_function

    # TODO: Think about how to input the secret
    def call(to_sign)
      text_to_sign = String to_sign.reduce(&:merge)
      hmac.hexdigest sha1, secret, text_to_sign
    end

    def hmac
      @hmac ||= OpenSSL::HMAC
    end

    def sha1
      @sha1 ||= OpenSSL::Digest::SHA1.new
    end
  end
end
