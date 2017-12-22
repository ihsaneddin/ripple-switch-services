module Ripples
  module Workers

    class WalletBroadcasterWorker
  
      include Sidekiq::Worker

      sidekiq_options :queue => :default, :retry => true, :backtrace => true

      def perform(wallet_id)
        wallet = Ripples::Models::Wallet.find(wallet_id)
        ActionCable.server.broadcast "wallet-#{wallet.address}", message: wallet.to_h
        ActionCable.server.broadcast "balance-#{wallet.account.id}", message: { total_balance: wallet.account.total_balance, total_balance_xrp: wallet.account.total_balance_xrp }.to_json
      end

    end
  end
end