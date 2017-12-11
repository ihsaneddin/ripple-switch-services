module Users
  module Models
    class Account < ::ApplicationRecord

      self.caches_suffix_list= ['collection', 'wallet-collection']
    
      # devise modules definition
      # :confirmable, :lockable, :timeoutable and :omniauthable
      devise :database_authenticatable, 
             :registerable,
             :recoverable, 
             :rememberable, 
             :trackable, 
             :validatable, 
             :confirmable, :authentication_keys => [:login]

      #
      # define attribute for username/email login
      #
      attr_accessor :login

      has_secure_token :token

      before_validation :set_username, on: :create
      before_create :generate_pin

      attr_encrypted :pin, key: ENV['ENCRYPT_SECRET_KEY']

      has_many :wallets, class_name: "Ripples::Models::Wallet"

      def generate_pin
        while true
          prop_pin = Base64.encode64(SecureRandom.random_bytes(12)).delete("\n")
          unless self.class.find_by_encrypted_pin(self.class.encrypt_pin(prop_pin)).present? 
            self.pin= prop_pin
            break
          end
        end
        self.pin
      end

      def change_pin
        new_pin = generate_pin
        if save
          debugger
          Users::Mailers::PinMailer.new_pin(self, new_pin).deliver
          new_pin
        else
          return false
        end
      end

      #
      # upon registration, if username is not specified then generate from email
      # 
      #
      def set_username
        suffix= nil
        while true
          propose = "#{self.email.split('@')[0]}#{suffix.present?? "_#{suffix}" : nil}"
          if self.class.where(username: propose).blank? 
            self.username = propose
            break;
          else
            suffix = suffix.to_i + 1
          end
        end        
      end

      def cached_wallet_collection(options={ condition: {} })
        Rails.cache.fetch("#{self.class.cached_name}-#{self.id}-wallet-collection", expires_in: 1.day) do 
          wallets.map(&:address)
        end
      end

      class << self

        def find_for_database_authentication warden_conditions, 
          conditions = warden_conditions.dup
          login = conditions.delete(:login)
          if login.present? 
            where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
          elsif conditions.has_key?(:username) || conditions.has_key?(:email)
            where(conditions.to_h).first
          end
        end

      end


    end
  end
end