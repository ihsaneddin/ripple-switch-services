module Ripples
  module Workers

    class WalletBroadcasterWorker
  
      include Sidekiq::Worker

      sidekiq_options :queue => :default, :retry => true, :backtrace => true

      def perform(wallet_id)
        wallet = Ripples::Models::Wallet.find(wallet_id)
        #ActionCable.server.broadcast "wallet-#{wallet.address}", message: wallet.to_json
        ActionCable.server.broadcast "balance-#{self.account.id}", message: 
                                                                          { total_balance: wallet.account.total_balance, 
                                                                            total_balance_xrp: wallet.account.total_balance_xrp, 
                                                                            wallets_pending_transactions_count: wallet.account.wallets_pending_transactions_count 
                                                                          }.to_json
      end

    end
  end
end