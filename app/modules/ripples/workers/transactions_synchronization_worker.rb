#
# this class is used to synchronize all transactions for current date
# subscriptions worker is doomed to fail if new wallet records keep inserted in the same time
# so this is the safest and the lame options
# this worker will be performed at scheduled time every day
# this worker only will be used on production environment 
# this worker fetch all transactions data for specified interval of between two times from `https://data.ripple.com/v2/transactions/` and inserted/updated to ripples_transactions_table
#

require 'connection/request'
require 'hashie/mash'

module Ripples
  module Workers
    class TransactionsSynchronizationWorker

      class_attribute :api_url
      class_attribute :interval

      self.api_url = 'https://data.ripple.com/v2/transactions'
      self.interval = 1.hour
    
      include Sidekiq::Worker

      sidekiq_options :queue => :critical, :retry => true, :backtrace => true

      def perform(opts=nil)
        return unless Rails.env.production?
        # prepare query params
        if opts.blank?
          # querying transactions from ripple api v2 between current date time and specified interval
          # limit query to max limit 100 transaction
          # specified result engine to `tesSUCCESS`
          to = DateTime.now
          from = (to - self.class.interval).strftime("%Y-%m-%dT%H:%M:%SZ")
          to = to.strftime("%Y-%m-%dT%H:%M:%SZ")
          marker = nil
          opts = { 
                    "params" => {
                              "start" => from,
                              "end" => to,
                              "result" => "tesSUCCESS",
                              "limit" => 100,
                              "type" => "Payment"
                            } 
                  }
        else
          # continue with query params from argument
          opts = Hashie::Mash.new(JSON.parse(opts))
        end

        #get all address present in database as Set object
        address_collection_set = Ripples::Models::Wallet.cached_with_deleted_collection.to_set

        # variable to contain transactions and need synchronization wallet objects
        transactions = []
        need_sync_addresses = []
        count = 0
        
        # querying to https://data.ripple.com/v2/transactions until last page
        loop do 
          opts["params"]["marker"]= marker
          data = fetch_data(opts)

          #if error happen when querying transactions then perform the job again
          if data.nil?
            self.class.perform_async(opts.to_json)
            break;
          end

          # set transactions object and set pagination marker from query response
          transactions = data.transactions || []
          marker = data.marker
          puts "\n++++ MARKER ++++\n"
          puts "++++ #{marker} ++++\n\n"
          puts "++++ COUNT ++++\n"
          puts "++++ #{count} ++++\n\n"
          # start loop transaction object

          # start transactions array loop
          transactions.each do |trans_json|

            # check if source account or destination account present in database
            # skip trans_json if receiver and sender are not present in database
            next unless address_collection_set.include?(trans_json.tx.Account) || address_collection_set.include?(trans_json.tx.Destination)

            # first check if tx_hash is already in database
            transaction = Ripples::Models::Transaction.find_or_initialize_by tx_hash: trans_json.hash
            
            # skip trans_json if transaction is already completed
            next if transaction.completed?
            
            if transaction.new_record?
              #if transaction object is a new record then process it
              transaction = process_new_transaction(trans_json)
            else
              # update transaction object if already present in database and not validated yet
              unless transaction.validated?
                transaction.validated = true
                transaction.state = 'completed'
              end
            end
            
            # add correspondent addresses to need_sync_address for later sync
            need_sync_addresses = need_sync_addresses + [trans_json.tx.Account, trans_json.tx.Destination]

            # save transaction
            transaction.save if transaction.changed?

          end
          count += opts["params"]["limit"]
          # break loop when transactions blank or the last page has been reached
          break if transactions.blank?
        end

        # update addresses balance
        # no need for these lines of code again
        #if need_sync_addresses.compact.present?
        #  need_sync_addresses = need_sync_addresses.uniq.compact
        #  Ripples::Models::Wallet.select("id", "address", "deleted_at", "balance", "encrypted_secret", "encrypted_secret_iv").with_deleted.where(address: need_sync_addresses ).each do |wallet|
        #    wallet.sync_balance
        #  end
        #end

        #schedule the job again at `to` + specified interval
        self.class.perform_at(to.to_datetime + self.class.interval)

      end

      #
      # fetch data transactions from ripple api v2 transaction endpoint
      #
      def fetch_data(opts)
        conn = ::Connection::Request.new :get, self.api_url, opts, ssl=true
        conn.invoke
        if conn.success?
          conn.response
        else
          nil
        end
      end

      def process_new_transaction trans_json= Hashie::Mash.new
        transaction = Ripples::Models::Transaction.new skip_submit: true
        #
        # there are bunch of TransactionType of ripple transaction object
        # for now we only process `Payment` type 
        #
        case trans_json.tx.try(:TransactionType)
        when "Payment"
          transaction.tx_hash = trans_json['hash']
          transaction.source = trans_json.tx.try(:Account)
          transaction.destination = trans_json.tx.try(:Destination)
          transaction.transaction_type = trans_json.try(:TransactionType)
          if trans_json.tx.Amount.kind_of? String
            transaction.amount = BigDecimal.new(trans_json.tx.Amount)
            transaction.destination_currency = "XRP"
          else
            transaction.amount = BigDecimal.new(trans_json.tx.Amount.value)
            transaction.destination_currency = trans_json.tx.Amount.currency
          end
          transaction.state = "closed"
          transaction.validated = true
        end
         transaction
      end

    end
  end
end