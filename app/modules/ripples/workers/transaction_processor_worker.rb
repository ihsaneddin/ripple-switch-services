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
          #ActiveRecord::Base.transaction do

            tx = res.transaction
            if tx.present?

              # get or initialize transaction object by tx_hash
              tx_hash = res["tx_hash"] || tx["hash"]
              # for now just skip if tx_hash is not present
              return unless tx_hash
              
              p [:tx_hash, tx_hash]
              trans = Ripples::Models::Transaction.find_or_initialize_by(tx_hash: tx_hash.to_s.strip)
                
              if trans.new_record?
                 # if transaction object is new record then store it on database
                 #trans.wallet= account
                 p [:info, "transaction with hash #{trans.tx_hash} is new transaction"]
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
                  # display error message if error happen
                  p [:unable_to_save_new_transaction, trans.errors.full_messages]
                  #raise ActiveRecord::RecordInvalid
                 end
              else
                #else if transaction object is exist then updated it by tx response
                p [:info, "transaction with hash #{trans.tx_hash} is existed"]
                if tx["Amount"].kind_of?(String)
                  trans.amount = BigDecimal.new(tx["Amount"]) # all transaction amount xrp is using drops
                  trans.destination_currency = "XRP"
                 else
                  transaction.amount = BigDecimal.new(tx.Amount.try(:value))
                  transaction.destination_currency = tx.Amount.try(:currency)
                end
                trans.state= res["status"]
                trans.validated= res["validated"]
                unless trans.save
                  p [:unable_to_save_existed_transaction, trans.errors.full_messages]
                  # handle same record that saved twice because sidekiq process it at exact same time
                  trans.class.where.not(id: trans.id).where(tx_hash: trans.tx_hash).each do |d_trans|
                    trans.validated= d_trans.validated if d_trans.validated
                    trans.state = d_trans.state if d_trans.state == 'close'
                    trans.amount = d_trans.amount if d_trans.amount > trans.amount
                    d_trans.really_destroy!
                  end
                  unless trans.save
                    p [:unable_to_save_existed_transaction_again, trans.errors.full_messages]
                  end
                end
              end
            end

          #end
        rescue => e 
          p [:rescue, e.message]
          p [:backtrace, e.backtrace]
          #raise ActiveRecord::Rollback unless Rails.env.production?
        end
      end

    end
  end
end