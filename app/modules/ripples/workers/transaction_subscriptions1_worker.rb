#
# This worker is used to stream transactions received or sent 
#

module Ripples
  module Workers

    class TransactionSubscriptions1Worker < BaseTransactionSubscriptionsWorker

      sidekiq_options :queue => :subscriptions1, :retry => true, :backtrace => true

    end

  end
end