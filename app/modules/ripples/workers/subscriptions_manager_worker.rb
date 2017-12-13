#
# this class is used to manage subscriptionsTransactionsWorker behave
# run this to initiate stream transactions
# it will start new SubscriptionTransactionsWorker process when new Ripples::Models::Wallet object is added to database
# and kill the previous SubscriptionTransactionsWorker process
#
module Ripples
  module Workers

    class SubscriptionsManagerWorker
  
      include Sidekiq::Worker

      def perform()
        puts "works!"
      end

    end

  end
end