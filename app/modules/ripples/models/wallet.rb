module Ripples
  module Models
    class Wallet < ::ApplicationRecord
      
      before_validation :generate_address, on: :create
      before_validation :set_sequence, on: :create

      attr_encrypted :secret, key: ENV['ENCRYPT_SECRET_KEY']

      include PgSearch
      pg_search_scope :search_by_label, :against => [:label]

      belongs_to :account, class_name: "Users::Models::Account"
      has_many :transactions, class_name: "Ripples::Models::Transaction"

      validates :label, uniqueness: { scope: :account_id, allow_blank: true }#, unless: Proc.new { |w| w.deleted_at.blank? }

      self.caches_suffix_list= ['wallet-cached-address', "collection"]

      notify_changes_after :create

      def should_notify?
        self.created_at == self.updated_at
      end

      class << self

        def filter(params={})
          res = cached_collection.where(nil)
          if params[:label].present?
            res = res.search_by_label(params[:label])
          end
          if params[:address].present?
            res = res.where(address: params[:address])
          end
          res
        end

        def address_collection
          Rails.cache.fetch("wallet-cached-address-collection", expires_in: 1.day) do 
            select('address', 'deleted_at').map(&:address).compact
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

    end
  end
end