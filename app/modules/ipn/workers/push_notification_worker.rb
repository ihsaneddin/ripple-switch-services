module IPN
  module Workers
    class PushNotificationWorker
      
      include Sidekiq::Worker

      sidekiq_options queue: :ipn, retry: true, backtrace: true

      def perform(recipient_id)
        recipient = recipient_class.find_by_id(recipient_id)
        if recipient
          recipient.push
        end
      end

      private

        def recipient_class
          IPN::Models::Recipient          
        end

    end
  end
end