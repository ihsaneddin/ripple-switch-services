module Users
  module Mailers
    class AccountMailer < BaseMailer
      
      default template_path: "accounts"
 
      def login_url(token)
        @token = token
        @account= token.account
        mail to: @account.email, subject: 'Login URL'
      end
    
    end
  end
end