module Administration
  module Models
    class Admin < ApplicationRecord
    
      # devise modules definition
      # :confirmable, :lockable, :timeoutable and :omniauthable
      devise :database_authenticatable, 
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