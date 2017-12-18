#
# This worker is used to expiring Users::Models::Subscription object
#

module Users
  module Workers

    class SubscriptionWorker 

      include Sidekiq::Worker

      sidekiq_options :queue => :critical, :retry => true, :backtrace => true

      def perform(subscription_id)
        subscription = Users::Models::Subscription.find(subscription_id)
        subscription.expiring!
        self.class.perform_async(subscription.id) unless subscription.expired?
      end

    end

  end
end