module Users
  module Mailers
    class PinMailer < BaseMailer
      
      default template_path: "pins"
      
      def new_pin(account_id)
        @account= Users::Models::Account.find_by_id account_id
        if @account
          @pin = @account.pin
          mail to: @account.email, subject: 'New PIN'
        end
      end
    
    end
  end
end