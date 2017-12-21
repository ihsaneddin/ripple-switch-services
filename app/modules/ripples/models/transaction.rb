module Ripples
  module Models
    class Transaction < ::ApplicationRecord

      belongs_to :wallet, class_name: "Ripples::Models::Wallet", touch: true, optional: true
    
      #validates :wallet_id, presence: true
      validates :amount, :presence => true, numericality: { greater_than: 0 }
      validates :destination, presence: true

      scope :completed, ->{ where(state: "closed") }

      after_save do 
        destination_wallet = Ripples::Models::Wallet.find_by(address: destination)
        if destination_wallet.present?
          destination_wallet.touch
          destination_wallet.try(:account).touch
        end
      end

      after_save do 
        wallet.try(:account).try(:touch)
      end

      before_create :submit, unless: :skip_submit

      attr_accessor :issuer, :skip_submit

      def default_attrs
        self.source_currency||= "XRP"
        self.destination_currency||= "XRP"
        self.destination.transaction_type||= "Payment"
      end

      def complete!
        update(state: "closed")
      end

      def completed?
        state == 'closed'
      end

      def submit
        destination_amount = wallet.ripple_client.new_amount(value: "#{self.amount.floor}", currency: self.destination_currency || 'XRP', issuer: self.issuer || self.destination )
        
        if destination_amount.currency == "XRP"
          destination_amount.value= "#{(self.amount * 1000000).floor}" # 1 xrp == 1 million drops
        end

        trans = wallet.ripple_client.new_transaction destination_account: self.destination.to_s.strip, destination_amount: destination_amount, 
                                        source_currency: self.destination_currency || 'XRP'
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
          if params[:addresses].present?
            res = res.joins(:wallet).where(ripples_wallets: { address: addresses })
          else
            res = res.where(wallet_id: params[:wallet_ids] || [])
          end

          if params[:tx_hash].present?
            res = res.where(tx_hash: params[:tx_hash])
          end
          if params[:destination].present?
            res = res.where(destination: params[:destination])
          end
          if params[:state].present?
            res = res.where(state: params[:state])
          end
          if params[:validated].present?
            res = res.where(validated: params[:validated])
          end
          if params[:before_date].present?
            before_date= Date.parse(params[:before_date]) rescue nil
            res = res.where("date(created_at) >= ?", before_date) if before_date
          end
          if params[:after_date].present?
            after_date= Date.parse(params[:after_date]) rescue nil
            res = res.where("date(created_at) >= ?", after_date) if after_date
          end
          if params[:from_time].present?
            from_time= DateTime.parse(params[:from_time]) rescue nil
            res = res.where("created_at >= ?", from_time) if from_time
          end
          if params[:to_time].present?
            to_time= DateTime.parse(params[:to_time]) rescue nil
            res = res.where("created_at <= ?", to_time) if to_time
          end
          
          res
        end

      end

    end
  end
end