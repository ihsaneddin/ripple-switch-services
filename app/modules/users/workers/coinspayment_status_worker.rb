#
# This worker is used to expiring Users::Models::Subscription object
#

module Users
  module Workers

    class CoinspaymentStatusWorker 

      include Sidekiq::Worker

      sidekiq_options :queue => :critical, :retry => true, :backtrace => true

      def perform()
        Users::Models::Subscription.need_coinspayment_status_collection.each do |subscription|
          next if subscription.txn_id.blank?
          Coinspayment.tx_info
        end
      end

    end

  end
end