#
# this worker will streams all transactions that passed the local rippled server
# if the worker fail it will restart itself but with start_time argument present
# the start_time argument is used to synchronize transaction between the start_time and the time after websocket receive its first message
# this worker always restarted if it crashed
#
module Ripples
  module Workers
    class TransactionsSubscriptionWorker
      
      include Sidekiq::Worker

      sidekiq_options :queue => 'transactions_subscriptions', retry: true, backtrace: true

      def perform(url=nil, start_time=nil)
        url||= ENV["WRIPPLED_SERVER"]

        sync_opts= start_time.present?? { params: { start: start_time, limit: 100, type: "Payment", result: "tesSUCCESS" } } : {}

        EM.run {
          ws = Faye::WebSocket::Client.new(url, nil, ping: 60)

          ws.on :open do |event|
            p [:open, self.class.name, DateTime.now]
            ws.send(subscribe_params.to_json)
          end

          ws.on :message do |event|
            #p [:message, self.class.name, DateTime.now]
            
            if sync_opts.present? && Rails.env.production?
              sync_opts[:params][:end]= DateTime.now.strftime("%Y-%m-%dT%H:%M:%SZ")
              Ripples::Workers::TransactionsSynchronizationWorker.perform_async(sync_opts.to_json)
              sync_opts= nil
            end

            res = Hashie::Mash.new(JSON.parse(event.data))
            is_transaction_will_be_processed?(res) do
              # Hashie::Mash override key with name `hash` so we have to store on another key first before serialize to json
              res.tx_hash= res.transaction["hash"] rescue nil
              p [:process, event.data]
              process_transaction(res)
            end
          
          end

          ws.on :close do |event|
            p [:close, self.class.name, event.code, event.reason, DateTime.now]
            #if the reason of terminating worker not from host restart the worker
            if (Integer(event.code) > 1000)
              self.class.perform_async(url, DateTime.now.strftime("%Y-%m-%dT%H:%M:%SZ"))
            end
            ws.send(unsubscribe_params.to_json)
            ws = nil
            EM.stop_event_loop
          end

          ws.onerror = lambda do |error|
            p [:error, self.class.name, error.message]
          end


          Signal.trap("INT")  { EventMachine.try(:stop) }
          Signal.trap("TERM") { EventMachine.try(:stop) }

        }
        
      end

      def subscribe_params
        { id: SecureRandom.urlsafe_base64(nil, false), streams: ["transactions_proposed"], command: "subscribe"}
      end

      def unsubscribe_params
        { id: SecureRandom.urlsafe_base64(nil, false), streams: ["transactions_proposed"], command: "unsubscribe"}
      end

      def process_transaction(res)
        if Rails.env.development?
          Ripples::Workers::TransactionProcessorWorker.new.perform(res.to_json)
        else
          Ripples::Workers::TransactionProcessorWorker.perform_async(res.to_json)
        end
      end

      #
      # return boolean to determine whether transaction will be processed or not
      # MUST BE FAST!
      #
      def is_transaction_will_be_processed?(res)
        if res.engine_result == 'tesSUCCESS' && res.transaction.try(:TransactionType) == "Payment"
          if Ripples::Models::Wallet.get(res.transaction.try(:Account)) || Ripples::Models::Wallet.get(res.transaction.try(:Destination))
            block_given?? yield : true
          end
        end
      end

    end
  end
end
