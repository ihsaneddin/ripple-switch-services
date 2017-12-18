module Users
  module Helpers
    module Account
      
      extend ActiveSupport::Concern

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
                Users::Mailers::PinMailer.delay.new_pin(account_id)
              end
            end
            return account.generate_token if account.persisted?
          end

          def login_by_token token=nil
            Users::Models::Token.find_and_authenticate token
          end

        end

      end

      module Wallets 
          
        extend ActiveSupport::Concern
        
        def cached_address_collection
          cached_wallet_collection.map(&:address)
        end

        def cached_wallet_collection
          Rails.cache.fetch("#{self.class.cached_name}-#{self.id}-wallet-collection", expires_in: 1.day) do 
            wallets.load
          end
        end

        def total_balance
          cached_wallet_collection.inject(0){|sum, wallet| sum + wallet.balance }
        end

        def total_balance_xrp
          cached_wallet_collection.inject(0){|sum, wallet| sum + wallet.balance_xrp }
        end

      end

      module Transactions

        extend ActiveSupport::Concern

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
            cached_wallets_pending_transactions.where(destination: cached_wallet_collection.map(&:address)).load
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

    end
  end
end