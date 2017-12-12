module Users
  module Mailers
    class PinMailer < BaseMailer
      
      default template_path: "pins"
      
      def new_pin(account, pin)
        @pin = pin
        @account= account
        mail to: account.email, subject: 'New PIN'
      end
    
    end
  end
end