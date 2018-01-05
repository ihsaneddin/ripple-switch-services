module Supports
  module Notifications
    module Workers
      class NotificationMailerWorker
        
        include Sidekiq::Worker

        sidekiq_options :queue => :notifications, backtrace: true, retry: true

        def perform(receipt_id)
          receipt= receipt_class.find_by_id(receipt_id)
          if receipt
            receipt.push
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