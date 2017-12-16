module Api
  module V1
    class Transactions < Api::V1::Base
      

      self.presenter_name= "Transaction"
      self.context_resource_class= 'Ripples::Models::Transaction'

      use_resource!

      include Users::Helpers::TransactionAuthorization::Grape

      helpers do 

        def transaction_params
          posts[:transaction] = posts
          posts.require(:transaction).permit(:amount, :destination, :destination_currency)
        end

        def existing_resource_finder
          @transaction ||= resource_class_constant.where(id: params[:id]).or(resource_class_constant.where(tx_hash: params[:id])).first
        end

        def merged_filter_params
          filter_params.merge!(wallet_ids: current_account.cached_wallet_collection.map(&:id))
        end

        def wallet
          @wallet ||= current_account.wallets.where(address: params[:wallet_id]).or(current_account.wallets.where(id: params[:wallet_id])).first
          return @wallet if @wallet
          raise ActiveRecord::RecordNotFound
        end

      end

      resources "transactions" do 

        desc "[GET] get all account's transactions"
        get do 
          transactions = resource_class_constant.filter(merged_filter_params)
          presenter paginate(transactions)
        end

        desc "[GET] get a transaction object by tx_hash or uuid"
        get ":id", requirements: { id: /[0-9]*/ } do 
          presenter context_resource
        end

      end

      resources "account_transactions" do

        desc "[GET] get count of pending transaction"
        get "pending_count" do
          current_account.wallets_pending_transactions_count
        end

        desc "[GET] get count of validated transaction"
        get "validated_count" do 
          current_account.wallets_validated_transactions_count
        end

      end

      resources "wallet/:wallet_id/transactions" do 

        desc "[POST] create a new transaction"
        post do 
          authorize_transaction do
            context_resource.wallet = wallet
            if context_resource.save
              presenter context_resource
            else
              standard_validation_error details: context_resource.errors
            end
          end
        end

      end

    end
  end
end