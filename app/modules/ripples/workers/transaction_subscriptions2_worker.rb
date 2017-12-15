#
# This worker is used to stream transactions received or sent 
#

module Ripples
  module Workers

    class TransactionSubscriptions2Worker < BaseTransactionSubscriptionsWorker

      sidekiq_options :queue => :subscriptions2, :retry => true, :backtrace => true

    end

  end
end