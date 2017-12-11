module Users
  module Mailers
    class PinMailer < ActionMailer::Base
      
      default :from => 'RSS <no-reply@rss.com>'
      default template_path: "pins"

      append_view_path Rails.root.join('app', 'modules', 'users', 'views', 'mailers')
      
      def new_pin(account, pin)
        @pin = pin
        @account= account
        mail to: account.email, subject: 'New PIN'
      end
    
    end
  end
end