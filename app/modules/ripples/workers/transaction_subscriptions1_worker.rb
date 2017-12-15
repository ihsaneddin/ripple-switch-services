#
# This worker is used to stream transactions received or sent 
#

require 'faye/websocket'
require 'eventmachine'

module Ripples
  module Workers

    class TransactionSubscriptions1Worker
  
      include Sidekiq::Worker

      sidekiq_options :queue => :subscriptions1, :retry => true, :backtrace => true

      def perform(wss)

        subscribe_params = { id: SecureRandom.urlsafe_base64(nil, false), accounts_proposed: Ripples::Models::Wallet.cached_address_collection, command: "subscribe"}

        unsubscribe_params = { id: SecureRandom.urlsafe_base64(nil, false), accounts_proposed: Ripples::Models::Wallet.cached_address_collection, command: "unsubscribe"}

        return if subscribe_params[:accounts_proposed].blank?

        EM.run {
          ws = Faye::WebSocket::Client.new(wss, nil, ping: 60)

          ws.on :open do |event|
            p [:open]
            ws.send(subscribe_params.to_json)
          end

          ws.on :message do |event|
            p [:message, event.data]
            res = Hashie::Mash.new(JSON.parse(event.data))
            
            if res.id.present? && res.id == unsubscribe_params[:id]
              ws= nil
            elsif res.status == 'error'
              perform(wss)
            else
              
              begin
                ActiveRecord::Base.transaction do

                  if res.engine_result_code == 0
                    trans_json = res.transaction
                    if trans_json.present?
                      account = Ripples::Models::Wallet.find_by_address trans_json["Account"]
                      trans = Ripples::Models::Transaction.find_or_initialize_by tx_hash: trans_json["hash"]
                      if trans.new_record?
                         trans.wallet= account
                         trans.destination = trans_json["Destination"]
                         trans.state = res["status"]
                         trans.amount = BigDecimal.new(trans_json["Amount"])
                         trans.transaction_date = trans_json['date']
                         trans.validated = trans_json["validated"]
                         trans.transaction_type = trans_json["type"]
                         trans.skip_submit= true
                         unless trans.save
                          puts trans.errors.full_messages
                          raise ActiveRecord::RecordInvalid
                         end
                      else
                        trans.update state: res["status"], validated: trans_json["validated"]
                      end

                      if trans.validated && trans.completed?
                        counter_parties = res.meta.AffectedNodes
                        if counter_parties.kind_of? Array
                          counter_parties.each do |modified_node|
                            new_balance = modified_node.FinalFields.Balance
                            if account.address == modified_node.FinalFields.Account
                              account.update balance: new_balance, validated: true
                            else
                              destination = Ripples::Models::Wallet.find_by_address modified_node.FinalFields.Balance
                              destination.update balance: new_balance, validated: true
                            end
                          end
                        end
                      end
                      
                    end
                  end

                end
              rescue => e 
                puts e.message
                puts e.backtrace
                raise ActiveRecord::Rollback
              end

            end
          end

          ws.on :close do |event|
            p [:close, event.code, event.reason]
            ws.send(unsubscribe_params.to_json)
            ws = nil
          end

          ws.onerror = lambda do |error|
            p [:error, error.message]
            # restart job if connection reset from server
            if error.message == 'Errno::ECONNRESET'
              Ripples::Workers::TransactionSubscriptions1Worker.perform_async(wss)
            end
          end


          Signal.trap("INT")  { EventMachine.stop }
          Signal.trap("TERM") { EventMachine.stop }

        }
      end

    end

  end
end

=begin
{"engine_result"=>"tesSUCCESS",
 "engine_result_code"=>0,
 "engine_result_message"=>
  "The transaction was applied. Only final in a validated ledger.",
 "ledger_hash"=>
  "84AD5A37AA306CA912264E935E51A13DCA8205C78FA144CA4CF86F0B18E7A44B",
 "ledger_index"=>4925550,
 "meta"=>
  {"AffectedNodes"=>
    [{"ModifiedNode"=>
       {"FinalFields"=>
         {"Account"=>"r98inwykJDVt7rMT1tiQNuuTXPKbhwxZeR",
          "Balance"=>"2000000000",
          "Flags"=>0,
          "OwnerCount"=>0,
          "Sequence"=>1},
        "LedgerEntryType"=>"AccountRoot",
        "LedgerIndex"=>
         "2A681BF370642885444A28C76CCBDAA4E70D4347A451289E3B325514F026A62C",
        "PreviousFields"=>{"Balance"=>"1000000000"},
        "PreviousTxnID"=>
         "049F04925B8B16619A29A77F24A0A74DA81804004FB150A9F69B8DA9543009B0",
        "PreviousTxnLgrSeq"=>4925525}},
     {"ModifiedNode"=>
       {"FinalFields"=>
         {"Account"=>"rwxDquZkNAF5kmHLyDSg6gF8apAQV2psTL",
          "Balance"=>"5979999940",
          "Flags"=>0,
          "OwnerCount"=>0,
          "Sequence"=>7},
        "LedgerEntryType"=>"AccountRoot",
        "LedgerIndex"=>
         "5E747D7D4ADDE850B7BB53D543C5A1FE9F2BFC3A9AA9B9E854E3D08C7576766F",
        "PreviousFields"=>{"Balance"=>"6979999950", "Sequence"=>6},
        "PreviousTxnID"=>
         "049F04925B8B16619A29A77F24A0A74DA81804004FB150A9F69B8DA9543009B0",
        "PreviousTxnLgrSeq"=>4925525}}],
   "TransactionIndex"=>0,
   "TransactionResult"=>"tesSUCCESS"},
 "status"=>"closed",
 "transaction"=>
  {"Account"=>"rwxDquZkNAF5kmHLyDSg6gF8apAQV2psTL",
   "Amount"=>"1000000000",
   "Destination"=>"r98inwykJDVt7rMT1tiQNuuTXPKbhwxZeR",
   "Fee"=>"10",
   "Flags"=>2147483648,
   "Sequence"=>6,
   "SigningPubKey"=>
    "0398D14326F2CAEA3F07801A3FDB014027422C02695F198C989B7F8604A8AB3487",
   "TransactionType"=>"Payment",
   "TxnSignature"=>
    "3045022100D0632253B33F9BEFF9FBE2535852C7F95001742847879D14144941060F1E865802203C122CC3789CD50E30F46400B742569A77BA64507253EEA081C5DBEC150F7818",
   "date"=>566467510,
   "hash"=>"3CCDE421572A1050C7BD87E8C984F3ECE54700030B33B8C0214BB322A205221D"},
 "type"=>"transaction",
 "validated"=>true}
=end