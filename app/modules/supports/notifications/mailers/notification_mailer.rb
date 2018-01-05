module Supports
  module Notifications
    module Mailers
      class NotificationMailer < BaseMailer
        
        default template_path: "notifications"

        def notify(receipt_id)
          @receipt= receipt_id
          unless @receipt.is_a?(receipt_class)
            @receipt = receipt_class.find_by_id(@receipt)
          end

          if @receipt
            @subject= @receipt.option_subject || @receipt.notification.subject
            @title= @receipt.option_title
            @body= @receipt.option_body || @receipt.notification.body
            mail to: @receipt.option_email, subject: @subject
          end
        end

        protected

          def receipt_class
            Supports::Notifications::Models::ReceiptTypes::Mail
          end

      end
    end
  end
end