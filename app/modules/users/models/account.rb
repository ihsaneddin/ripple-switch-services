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

      validates :email, uniqueness: true, format: /\A[^@\s]+@[^@\s]+\z/ 

      has_secure_token :token

      before_validation :set_username, on: :create
      before_create :generate_pin

      attr_encrypted :pin, key: ENV['ENCRYPT_SECRET_KEY']

      has_many :wallets, class_name: "Ripples::Models::Wallet"
      has_many :tokens, class_name: "Users::Models::Token"

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

      module RegistrationOrLoginByToken

        extend ActiveSupport::Concern

        def generate_token
          self.tokens.create
        end

        module ClassMethods
          
          def registration_or_generate_login_by_token params={}
            account = Users::Models::Account.find_by email: params[:email]
            unless account
              account = Users::Models::Account.new email: params[:email], password: SecureRandom.base64
              account.skip_confirmation!
              if account.save
                Users::Mailers::PinMailer.new_pin(account, account.pin).deliver
              end
            end
            return account.generate_token
          end

          def login_by_token token=nil
            Users::Models::Token.find_and_authenticate token
          end

        end

      end

      include Users::Models::Account::RegistrationOrLoginByToken

    end
  end
end