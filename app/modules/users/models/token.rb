module Users
  module Models
    class Token < ApplicationRecord
    
      belongs_to :account, class_name: "Users::Models::Account"

      before_create :generate_token
      before_create :set_expired_at

      def set_expired_at
        self.expired_at||= DateTime.now + 1.day
      end

      def generate_token
        self.token = loop do
                      random_token = SecureRandom.urlsafe_base64(nil, false)
                      break random_token unless self.class.exists?(token: random_token)
                    end
      end

      def expired?
        self.expired_at <= DateTime.now
      end

      def expiring!
        self.delete if expired? 
      end

      class << self

        def find_and_authenticate token= nil
          token = find_by_token token
          if token
            token.expiring!
            token.deleted?? nil : token
          end
        end

      end

    end
  end
end