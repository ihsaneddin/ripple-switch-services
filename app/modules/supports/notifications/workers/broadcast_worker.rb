module Supports
  module Notifications
    module Workers
      class BroadcastWorker 
        
        include Sidekiq::Worker

        sidekiq_options queue: :notifications, retry: true, backtrace: true

        def perform(receipt_id)
          receipt = receipt_class.find_by_id(receipt_id)
          if receipt
            receipt.push
          end
        end

        protected

          def receipt_class
            Supports::Notifications::Models::ReceiptTypes::Common 
          end

      end
    end
  end
end