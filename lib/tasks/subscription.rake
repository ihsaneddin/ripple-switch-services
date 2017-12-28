namespace :subscription do
  
  namespace :accounts do
    desc "Start AccountsSubscriptionsManagerWorker class"
    task start_accounts_subscriptions_manager_worker: :environment do
      Ripples::Workers::AccountsSubscriptionsManagerWorker.perform_async
    end
  end

  namespace :transactions do
    desc "Start a Subscriptions Transactions stream worker"
    task start_transactions_subscription_worker: :environment do
      Ripples::Workers::TransactionsSubscriptionWorker.perform_async
    end
  end

  namespace :redis do
    desc "If the redis-server restarted. Run this task to generate key from address on Ripples::Models::Wallet and key from tx_hash on Ripples::Models::Transaction"
    task :store_wallet_addresses_and_tx_hash => :environment do 
      Ripples::Models::Wallet.select("id", "created_at", "deleted_at", "updated_at", "address").with_deleted.each {|wallet| wallet.try(:map_to_redis) }
      Ripples::Models::Transaction.select("id", "created_at", "deleted_at", "updated_at", "tx_hash").with_deleted.each {|wallet| wallet.try(:map_to_redis) }
    end
  end

end