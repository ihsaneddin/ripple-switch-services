module Supports
  module Notifications
    module Mailers
      class NotificationMailer < BaseMailer

        default template_path: "notifications"

        def notify(receipt_id, opts={})
          @receipt= receipt_id
          @opts = opts
          unless @receipt.is_a?(receipt_class)
            @receipt = receipt_class.find_by_id(@receipt)
          end

          if @receipt
            @subject= @receipt.option_subject || @receipt.notification.subject
            @title= @receipt.option_title
            @body= @receipt.option_body || @receipt.notification.body

            if @receipt.option_append_view_path.present?
              vr = ActionView::OptimizedFileSystemResolver.new @receipt.option_append_view_path
              if self._view_paths.include?(vr)
                mail to: @receipt.option_email, subject: @subject,
                  template_name: @receipt.option_template_name || 'notify',
                  template_path: @receipt.option_template_path || "notifications"
              else
                self.class.append_view_path Pathname.new(@receipt.option_append_view_path)
                self.class.notify(@receipt, @opts).deliver
              end
            end
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