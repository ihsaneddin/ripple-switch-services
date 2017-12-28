#
# This worker is used to stream transactions received or sent 
#

module Ripples
  module Workers

    class AccountsSubscription2Worker < BaseTransactionAccountsSubscriptionsWorker

      sidekiq_options :queue => :accounts_subscription2, :retry => true, :backtrace => true

    end

  end
end