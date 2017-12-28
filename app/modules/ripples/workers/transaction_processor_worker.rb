#
# worker to insert or update transaction based on response from ripple transactions subscription websocket API
#
module Ripples
  module Workers
    class TransactionProcessorWorker
      
      include Sidekiq::Worker

      sidekiq_options :queue => 'critical', retry: true, backtrace: true

      def perform(res=nil)
        res = Hashie::Mash.new(JSON.parse(res))
        begin
          ActiveRecord::Base.transaction do

            tx = res.transaction
            if tx.present?

              # get or initialize transaction object by tx_hash
              trans = Ripples::Models::Transaction.find_or_initialize_by tx_hash: tx["hash"]
                
              if trans.new_record?
                 # if transaction object is new record then store it on database
                 #trans.wallet= account
                 trans.source= tx["Account"]
                 trans.destination = tx["Destination"]
                 trans.state = res["status"]
                 if tx["Amount"].kind_of?(String)
                  trans.amount = BigDecimal.new(tx["Amount"]) # all transaction amount xrp is using drops
                  trans.destination_currency = "XRP"
                 else
                  transaction.amount = BigDecimal.new(tx.Amount.try(:value))
                  transaction.destination_currency = tx.Amount.try(:currency)
                 end
                 trans.transaction_date = tx['date']
                 trans.validated = res["validated"]
                 trans.transaction_type = res["type"]
                 trans.skip_submit= true
                 unless trans.save
                  puts trans.errors.full_messages
                  raise ActiveRecord::RecordInvalid
                 end
              else
                #else if transaction object is exist then updated it by tx response
                trans.update state: res["status"], validated: res["validated"]
              end
            end

          end
        rescue => e 
          puts e.message
          puts e.backtrace
          raise ActiveRecord::Rollback unless Rails.env.production?
        end
      end

    end
  end
end