module Ripples
  module Models
    class Transaction < ::ApplicationRecord

      belongs_to :wallet, class_name: "Ripples::Models::Wallet", touch: true, optional: true
    
      #validates :wallet_id, presence: true
      validates :amount, :presence => true, numericality: { greater_than: 0 }
      validates :destination, presence: true

      after_save do 
        destination_wallet = Ripples::Models::Wallet.find_by(address: destination).present?
        if destination_wallet.present? && (self.state == 'closed') && state_before_last_save.blank?
          destination_wallet.touch
        end
      end

      before_create :submit, unless: :skip_submit

      attr_accessor :issuer, :skip_submit

      def complete!
        update(state: "closed")
      end

      def completed?
        state == 'closed'
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

      def xrp_amount
        (self.amount * 1000000).floor
      end

      class << self

        def filter(params={})
          res = cached_collection
          if params[:wallet_id].present?
            res = res.join(:wallet).where("ripples_wallets.id = :wallet_id or ripples_wallets.address = :wallet_id", params[:wallet_id])
          else
            res = res.where(wallet_id: params[:wallet_ids] || [])
          end
          if params[:tx_hash].present?
            res = res.where(tx_hash: params[:tx_hash])
          end
          res
        end

      end

    end
  end
end