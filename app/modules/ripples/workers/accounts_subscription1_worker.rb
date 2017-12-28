#
# This worker is used to stream transactions received or sent 
#

module Ripples
  module Workers

    class AccountsSubscription1Worker < BaseTransactionAccountsSubscriptionsWorker

      sidekiq_options :queue => :accounts_subscription1, :retry => true, :backtrace => true

    end

  end
end