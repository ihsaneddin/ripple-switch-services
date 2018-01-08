module Users
  module Mailers
    class AccountMailer < BaseMailer

      default template_path: "accounts"

      def login_url(token)
        @token = Users::Models::Token.find_by_token token
        if @token
          @account= @token.account
          mail to: @account.email, subject: 'Login URL'
        end
      end

    end
  end
end