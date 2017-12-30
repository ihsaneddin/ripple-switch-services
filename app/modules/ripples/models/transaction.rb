#
# Amount XRP is in drops
#
module Ripples
  module Models
    class Transaction < ::ApplicationRecord

      belongs_to :wallet, class_name: "Ripples::Models::Wallet", touch: true, optional: true
    
      #validates :wallet_id, presence: true
      validates :amount, :presence => true, numericality: { greater_than: 0 }
      validates :destination, presence: true
      validates :tx_hash, uniqueness: { allow_blank: true }

      scope :completed, ->{ where(state: "closed", validated: true) }
      scope :not_completed, -> { where.not(state: "closed").or(where(validated: false)) }

      #
      # map tx_hash as key and id as value to redis hash
      #
      map_attributes key: :tx_hash, value: :id, callback: :after_create

      #
      # sync wallet balance if transaction is validated
      #
      after_commit do 
        if saved_change_to_validated? && validated?
          source_wallet.try(:sync_balance)
          destination_wallet.try(:sync_balance)
        end
      end

      #
      # insert source address as wallet if source address present in wallets table
      #
      before_create do 
        if self.source.present?
          self.wallet||= Ripples::Models::Wallet.with_deleted.find_by_address(self.source)
        end
      end


      #
      # submit transaction to ripple server unless skip_submit is present or tx_hash is present
      #
      before_create :submit, unless: :skip_submit

      attr_accessor :issuer, :skip_submit

      #
      # default attrs before submitting transaction
      #
      def default_attrs
        self.source_currency||= "XRP"
        self.destination_currency||= "XRP"
        self.destination.transaction_type||= "Payment"
      end

      #
      # alias method for `wallet`
      #
      def source_wallet
        wallet
      end

      #
      # get destination wallet object if exists
      #
      def destination_wallet
        @destination_wallet||= Ripples::Models::Wallet.cached_collection.find_by_address(destination)
      end

      #
      # change state of transaction to complete
      #
      def complete!
        update(state: "closed", validated: true)
      end

      def completed?
        validated || (state == 'closed')
      end

      #
      # check whether transaction is validated
      #
      def validated?
        validated
      end

      #
      # submit new transaction to ledger
      #
      def submit
        if self.tx_hash.blank?
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
          end
          throw(:abort) if errors.any?
        end
      end

      #
      # get xrp amount of transaction
      #
      def xrp_amount
        (self.amount / 1000000).floor
      end

      #
      # get amount and its currency
      #
      def amount_with_currency
        if destination_currency.blank? || destination_currency.eql?('XRP')
          "#{xrp_amount} XRP"
        else
          "#{amount} #{destination_currency}"
        end
      end

      class << self

        #
        # filter records
        #
        def filter(params={})
          res = cached_collection
          if params[:addresses].present?
            res = res.joins(:wallet).where(ripples_wallets: { address: addresses })
          elsif params[:wallet_ids].present?
            res = res.where(wallet_id: params[:wallet_ids]).or(res.where(destination: params[:wallet_ids]))
          end

          if params[:address].present?
            res = res.where(source: params[:address])
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