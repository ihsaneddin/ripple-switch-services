module Supports
  module DecryptRequest
    module Models
      class Request < ApplicationRecord

        belongs_to :requester, polymorphic: true
        belongs_to :decrypted, polymorphic: true

        before_validation :generate_key

        def generate_key
          key= ActiveSupport::KeyGenerator.new(pin).generate_key(SecureRandom.random_bytes(64), 32)
        end

      end
    end
  end
end