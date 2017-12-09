require 'rqrcode'

module Ripples
  module Models
    class Wallet < ::ApplicationRecord
      
      before_validation :generate_address, on: :create
      before_validation :set_sequence, on: :create

      attr_encrypted :address, key: ENV['ENCRYPT_SECRET_KEY']
      attr_encrypted :secret, key: ENV['ENCRYPT_SECRET_KEY']

      include PgSearch
      pg_search_scope :search_by_label, :against => [:label]

      belongs_to :account, class_name: "Users::Models::Account"
      has_many :transactions, class_name: "Ripples::Models::Transaction"

      validates :label, uniqueness: { scope: :account_id }, unless: Proc.new { |w| w.deleted_at.blank? }

      class << self

        def filter(params={})
          res = cached_collection.where(nil)
          if params[:label]
            res = res.search_by_label(params[:label])
          end
          res
        end

      end

      def set_sequence
        self.sequence= self.class.where(account: self.account).count
      end

      def generate_address
        if Rails.env.development?
          resp = $rippleOfflineClient.dev_wallet_propose
          if resp.raw.present?
            self.address= resp.raw.address
            self.secret= resp.raw.secret
          end
        else
          resp = $rippleOfflineClient.wallet_propose
          if resp.raw.present?
            self.address= resp.resp.account_id
            self.secret= resp.resp.master_seed
          end
        end
      end

      def qr_code
        @qr_code||= RQRCode::QRCode.new( self.address, :size => 4, :level => :h )
      end

      def ripple_client(opts ={})
        @ripple_client ||= Ripple.client({ endpoint: ENV['RIPPLED_SERVER'], client_account: self.address, client_secret: self.secret }.merge!(opts))
      end

      def get_xrp_balance
        ripple_client.xrp_balance        
      end

    end
  end
end