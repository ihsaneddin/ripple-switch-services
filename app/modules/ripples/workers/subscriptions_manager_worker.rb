#
# this class is used to manage subscriptionsTransactions{n}Worker behave
# run this to initiate stream transactions
# it will start new SubscriptionTransactionsWorker process when new Ripples::Models::Wallet object is added to database
# and kill the previous SubscriptionTransactionsWorker process
#
module Ripples
  module Workers

    class SubscriptionsManagerWorker
  
      include Sidekiq::Worker

      attr_accessor :prev_jid, :new_jid

      sidekiq_options :queue => :subscriptions_manager, :retry => true, :backtrace => true

      def perform()
        
        # start new subscriptions worker no 1
        Ripples::Workers::TransactionSubscriptions1Worker.perform_async(ENV["WRIPPLED_SERVER"])

        available_workers = []

        # listen to changes of table ripples_wallets
        Ripples::Models::Wallet.on_table_change do |wallet|
          
          worker_class = Ripples::Workers::TransactionSubscriptions1Worker
          pro = nil 
          # start the new worker and stop the other
          Sidekiq::ProcessSet.new.each do |process|  
            if process["queues"].include?("subscriptions1")
              pro = Sidekiq::Process.new "identity" => process["identity"]
              worker_class = TransactionSubscriptions2Worker
              break
            end
            if process["queues"].include?("subscriptions2")
              pro = Sidekiq::Process.new "identity" => process["identity"]
              worker_class = TransactionSubscriptions1Worker
              break
            end
          end
          worker_class.perform_async(ENV["WRIPPLED_SERVER"])
          
          #
          # check if worker_class is running then terminate the other
          #

          pro.try(:stop!)

          puts "\n\n ASUP"
        
          Signal.trap("INT")  { break }
          Signal.trap("TERM") { break }

        end

      end

    end

  end
end