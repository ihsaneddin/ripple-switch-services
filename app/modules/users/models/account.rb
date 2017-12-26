module Users
  module Models
    class Account < ::ApplicationRecord

      self.caches_suffix_list= ['collection']
      self.object_caches_suffix= ['wallet-collection']
    
      # devise modules definition
      # :confirmable, :lockable, :timeoutable and :omniauthable
      devise :database_authenticatable, 
             :registerable,
             :recoverable, 
             :rememberable, 
             :trackable, 
             :validatable, 
             :confirmable, :authentication_keys => [:login]

      #
      # define attribute for username/email login
      #
      attr_accessor :login

      validates :email, uniqueness: true, format: /\A[^@\s]+@[^@\s]+\z/ 

      has_secure_token :token

      before_validation :set_username, on: :create
      before_create :generate_pin

      attr_encrypted :pin, key: ENV['ENCRYPT_SECRET_KEY']

      has_many :wallets, class_name: "Ripples::Models::Wallet"
      has_many :tokens, class_name: "Users::Models::Token"
      has_many :subscriptions, class_name: "Users::Models::Subscription"
      has_one :subscription_active, -> { where(state: "active") }, class_name: "Users::Models::Subscription"
      has_many :plans, class_name: "Users::Models::Plan", through: :subscriptions

      #
      # pg_search implementation
      #
      pg_search_scope :search_by_login, :against => [:email, :username]

      def generate_pin
        while true
          prop_pin = Base64.encode64(SecureRandom.random_bytes(12)).delete("\n")
          unless self.class.find_by_encrypted_pin(self.class.encrypt_pin(prop_pin)).present? 
            self.pin= prop_pin
            break
          end
        end
        self.pin
      end

      def change_pin
        new_pin = generate_pin
        if save
          Users::Mailers::PinMailer.delay.new_pin(self.id)
          new_pin
        else
          return false
        end
      end

      #
      # upon registration, if username is not specified then generate from email
      # 
      #
      def set_username
        suffix= nil
        while true
          propose = "#{self.email.split('@')[0]}#{suffix.present?? "_#{suffix}" : nil}"
          if self.class.where(username: propose).blank? 
            self.username = propose
            break;
          else
            suffix = suffix.to_i + 1
          end
        end        
      end

      module Wallets 
          
        extend ActiveSupport::Concern

        included do 

          self.object_caches_suffix += ['wallets-with-deleted-collection', 'wallets-only-deleted-collection', 'wallet-collection']

        end
        
        def cached_address_collection
          cached_wallet_collection.map(&:address)
        end

        def cached_wallets_with_deleted_collection
          Rails.cache.fetch("#{self.cache_prefix}-wallets-with-deleted-collection", expires_in: 1.day) do 
            self.wallets.with_deleted.load
          end
        end

        def cached_wallets_only_deleted_collection
          Rails.cache.fetch("#{self.cache_prefix}-wallets-only-deleted-collection", expires_in: 1.day) do 
            self.wallets.only_deleted.load
          end
        end

        def cached_wallet_collection
          Rails.cache.fetch("#{self.cache_prefix}-wallet-collection", expires_in: 1.day) do 
            self.wallets.load
          end
        end

        def total_balance
          cached_wallet_collection.inject(0){|sum, wallet| sum + wallet.balance }
        end

        def total_balance_xrp
          cached_wallet_collection.inject(0){|sum, wallet| sum + wallet.balance_xrp }
        end

      end
      include Users::Models::Account::Wallets

      module Transactions

        extend ActiveSupport::Concern

        included do 

          self.object_caches_suffix += ['wallets-received-validated-transactions', 
                                        'wallets-sent-pending-transactions', 'wallets-received-pending-transactions', 
                                        'wallets-transactions', "wallets-sent-transactions", 
                                        "wallets-received-transactions", 'wallets-pending-transactions', 
                                        'wallets-validated-transactions', 'wallets-sent-validated-transactions'
                                        ]

        end

        def cached_wallets_transactions
          Rails.cache.fetch("#{self.class.cached_name}-#{self.id}-wallets-transactions", expires_in: 1.day) do 
            Ripples::Models::Transaction.filter(wallet_ids: cached_wallet_collection.map(&:id)).load
          end
        end

        def wallets_pending_transactions_count
          cached_wallets_transactions.inject(0){|count, tr| count + ( tr.validated ? 0 : 1 ) }
        end

        def wallets_validated_transactions_count
          cached_wallets_transactions.inject(0){|count, tr| count + ( tr.validated ? 1 : 0 ) }
        end

        def cached_wallets_sent_transactions
          Rails.cache.fetch("#{self.class.cached_name}-#{self.id}-wallets-sent-transactions", expires_in: 1.day) do 
            Ripples::Models::Transaction.filter(wallet_ids: cached_wallet_collection.map(&:id)).load
          end
        end

        def cached_wallets_received_transactions
          Rails.cache.fetch("#{self.class.cached_name}-#{self.id}-wallets-received-transactions", expires_in: 1.day) do 
            Ripples::Models::Transaction.filter(destination: cached_wallet_collection.map(&:address)).load
          end
        end

        def cached_wallets_pending_transactions
          Rails.cache.fetch("#{self.class.cached_name}-#{self.id}-wallets-pending-transactions", expires_in: 1.day) do 
            Ripples::Models::Transaction.filter(wallet_ids: cached_wallet_collection.map(&:id), validated: false).load
          end
        end

        def cached_wallets_validated_transactions
          Rails.cache.fetch("#{self.class.cached_name}-#{self.id}-wallets-validated-transactions", expires_in: 1.day) do 
            Ripples::Models::Transaction.filter(wallet_ids: cached_wallet_collection.map(&:id), validated: true).load
          end
        end

        def cached_wallets_sent_validated_transactions
          Rails.cache.fetch("#{self.class.cached_name}-#{self.id}-wallets-sent-validated-transactions", expires_in: 1.day) do
            cached_wallets_validated_transactions.where(wallet_id: cached_wallet_collection.map(&:id)).load
          end
        end

        def cached_wallets_received_validated_transactions
          Rails.cache.fetch("#{self.class.cached_name}-#{self.id}-wallets-received-validated-transactions", expires_in: 1.day) do
            cached_wallets_validated_transactions.where(destination: cached_wallet_collection.map(&:address)).load
          end
        end

        def cached_wallets_sent_pending_transactions
          Rails.cache.fetch("#{self.class.cached_name}-#{self.id}-wallets-sent-pending-transactions", expires_in: 1.day) do
            cached_wallets_pending_transactions.where(wallet_id: cached_wallet_collection.map(&:id)).load
          end
        end

        def cached_wallets_received_pending_transactions
          Rails.cache.fetch("#{self.class.cached_name}-#{self.id}-wallets-received-pending-transactions", expires_in: 1.day) do
            cached_wallets_received_transactions.where(validated: false).load
          end
        end

        def wallets_sent_transactions_count
          cached_wallets_sent_transactions.count
        end

        def wallets_received_transactions_count
          cached_wallets_received_transactions.count
        end

        def wallets_sent_pending_transactions_count
          cached_wallets_sent_pending_transactions.count
        end

        def wallets_sent_validated_transactions_count
          cached_wallets_sent_validated_transactions.count
        end

        def wallets_received_pending_transactions_count
          cached_wallets_received_pending_transactions.count
        end

        def wallets_received_validated_transactions_count
          cached_wallets_received_validated_transactions.count
        end

      end
      include Users::Models::Account::Transactions

      class << self

        def find_for_database_authentication warden_conditions, 
          conditions = warden_conditions.dup
          login = conditions.delete(:login)
          if login.present? 
            where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
          elsif conditions.has_key?(:username) || conditions.has_key?(:email)
            where(conditions.to_h).first
          end
        end

        def filter params={}
          res = cached_collection
          if params[:login].present?
            res = res.search_by_login(params[:login])
          end
          if params[:from_time].present?
            from_time= DateTime.parse(params[:from_time]) rescue nil
            res = res.where("updated_at >= ?", from_time) if from_time
          end
          if params[:to_time].present?
            to_time= DateTime.parse(params[:to_time]) rescue nil
            res = res.where("updated_at <= ?", to_time) if to_time
          end
          if params[:plan_id].present?
            res = res.joins(:subscription_active).where(users_subscriptions: { plan_id: params[:plan_id] })
          end
          res
        end

      end

      module RegistrationOrLoginByToken

        extend ActiveSupport::Concern

        def generate_token
          self.tokens.create
        end

        module ClassMethods
          
          def registration_or_generate_login_by_token params={}
            account = Users::Models::Account.find_by email: params[:email]
            unless account
              account = Users::Models::Account.new email: params[:email], password: SecureRandom.base64
              account.skip_confirmation!
              if account.save
                Users::Mailers::PinMailer.delay.new_pin(account.id)
              end
            end
            return account.generate_token if account.persisted?
          end

          def login_by_token token=nil
            Users::Models::Token.find_and_authenticate token
          end

        end

      end

      include Users::Models::Account::RegistrationOrLoginByToken

      module Subscriptions

        extend ActiveSupport::Concern

        included do 

          after_create :attach_to_free_plan

          self.object_caches_suffix += ['subscriptions', 'draft-subscription']

        end

        def attach_to_free_plan
          subscription = Users::Models::Plan.create_subscription_for self, "Free"
          subscription.confirm_free_plan! if subscription
        end

        def cached_subscriptions
          Rails.cache.fetch("#{self.class.cached_name}-#{self.id}-subscriptions", expires_in: 1.day) do 
            subscriptions.includes(:plan).desc.load
          end
        end

        def draft_subscription
          Rails.cache.fetch("#{self.cache_prefix}-draft-subscription", expires_in: 1.day) do 
            subscriptions.draft.last
          end
        end

        def active_subscription
          cached_subscriptions.active.try(:first) #|| subscriptions.new
        end

        def active_plan
          active_subscription.try(:plan) #|| Users::Models::Plan.free.first
        end

      end

      include Users::Models::Account::Subscriptions

    end
  end
end