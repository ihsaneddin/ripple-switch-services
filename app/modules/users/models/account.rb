module Users
  module Models
    class Account < ::ApplicationRecord
    
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