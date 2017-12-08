module Ripples
  module Models
    class Transaction < ::ApplicationRecord

      belongs_to :wallet, class_name: "Ripples::Models::Wallet", touch: true
    
      validates :wallet_id, presence: true
      validates :amount, :presence => true, numericality: { greater_than: 0 }
      validates :destination, presence: true

      before_create :submit

      attr_accessor :issuer

      def complete!
        update(status: "completed")
      end

      def submit
        destination_amount = wallet.ripple_client.new_amount(value: "#{self.amount.floor}", currency: self.currency || 'XRP', issuer: self.issuer || self.destination )
        
        if destination_amount.currency == "XRP"
          destination_amount.value= "#{(self.amount * 1000000).floor}" # 1 xrp == 1 million drops
        end

        trans = wallet.ripple_client.new_transaction destination_account: self.destination.to_s.strip, destination_amount: destination_amount, 
                                        source_currency: self.currency || 'XRP'
        begin
          
          trans = wallet.ripple_client.sign_transaction(trans)
          self.tx_hash= wallet.ripple_client.submit_transaction(trans) 
        rescue Ripple::SubmitFailed, Ripple::InvalidParameters, Ripple::ServerUnavailable, Ripple::Timedout => e
          self.errors.add(:destination, e.message)
          throw :abort
        end
      end

    end
  end
end