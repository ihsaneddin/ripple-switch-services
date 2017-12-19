module Ripples
  module Models
    class Wallet < ::ApplicationRecord

      self.object_caches_suffix= ['transactions', "received-transactions", "sent-transactions", 
                                  "with-deleted-collection", "with-only-deleted-collection"]
      
      before_validation :generate_address, on: :create
      before_validation :set_sequence, on: :create
      before_validation :generate_label, on: :create

      attr_encrypted :secret, key: ENV['ENCRYPT_SECRET_KEY']

      include PgSearch
      pg_search_scope :search_by_label, :against => [:label]

      belongs_to :account, class_name: "Users::Models::Account",touch: true
      has_many :transactions, class_name: "Ripples::Models::Transaction"

      validates :label, uniqueness: { scope: :account_id, allow_blank: true }#, unless: Proc.new { |w| w.deleted_at.blank? }

      self.caches_suffix_list= ['address-collection', "collection"]

      notify_changes_after :create

      def should_notify?
        self.created_at == self.updated_at
      end

      def generate_label
        self.label||= SecureRandom.urlsafe_base64(nil, false)
      end

      class << self

        def filter(params={})
          if params[:archived]
            res = only_deleted
          else
            res = cached_collection.where(nil)
          end
          if params[:label].present?
            res = res.search_by_label(params[:label])
          end
          if params[:address].present?
            res = res.where(address: params[:address])
          end
          if params[:validated].present?
            res = res.where(validated: params[:validated])
          end
          res
        end

        def address_collection
          cached_address_collection
        end

        def cached_address_collection
          Rails.cache.fetch("#{self.cached_name}-address-collection", expires_in: 1.day) do 
            select('address', 'deleted_at').map(&:address).compact
          end
        end

        def cached_with_deleted_collection
          Rails.cache.fetch("#{self.cached_name}-with-deleted-collection", expires_in: 1.day) do 
            self.with_deleted.load
          end
        end

        def cached_only_deleted_collection
          Rails.cache.fetch("#{self.cached_name}-with-only-deleted-collection", expires_in: 1.day) do 
            self.only_deleted.load
          end
        end

      end

      def set_sequence
        self.sequence= self.class.where(account: self.account).count
      end

      def generate_address
        if Rails.env.development?
          resp = $rippleClient.dev_wallet_propose
          if resp.raw.present?
            self.address= resp.raw.address
            self.secret= resp.raw.secret
          end
        else
          resp = $rippleClient.wallet_propose
          if resp.raw.present?
            self.address= resp.resp.account_id
            self.secret= resp.resp.master_seed
          end
        end
      end

      def ripple_client(opts ={})
        @ripple_client ||= $rippleClient
        @ripple_client.client_account= self.address
        @ripple_client.client_secret= self.secret
        @ripple_client
      end

      def balance_xrp
        (self.balance / 1000000).floor
      end

      module Transactions

        extend ActiveSupport::Concern

        def cached_transactions
          Rails.cache.fetch("#{self.class.cached_name}-#{self.id}-transactions", expires_in: 1.day) do 
            transactions.load
          end
        end

        def cached_received_transactions
          Rails.cache.fetch("#{self.class.cached_name}-#{self.id}-received-transactions", expires_in: 1.day) do 
            cached_transactions.where(destination: self.address).load
          end
        end

        def cached_sent_transactions
          Rails.cache.fetch("#{self.class.cached_name}-#{self.id}-sent-transactions", expires_in: 1.day) do 
            cached_transactions.where(wallet_id: self.id).load
          end
        end

        def pending_received_transactions_count
          cached_received_transactions.inject(0){|count, tr| count + (tr.validated?? 0 : 1) }
        end

        def validated_received_transactions_count
          cached_received_transactions.inject(0){|count, tr| count + (tr.validated?? 1 : 0) }
        end

        def pending_sent_transactions_count
          cached_sent_transactions.inject(0){|count, tr| count + (tr.validated?? 0 : 1) }
        end

        def validated_sent_transactions_count
          cached_sent_transactions.inject(0){|count, tr| count + (tr.validated?? 1 : 0) }
        end

      end

      include Ripples::Models::Wallet::Transactions


    end
  end
end