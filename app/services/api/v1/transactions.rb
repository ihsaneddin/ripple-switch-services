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
          posts.require(:transaction).permit!(:amount, :destination)
        end

        def existing_resource_finder
          @transaction ||= resource_class_constant.where(id: params[:id]).or(resource_class_constant.where(tx_hash: params[:id])).first
        end

        def merged_filter_params
          filter_params.merge!(wallet_ids: current_accont.wallet_collection.map(&:id))
        end

        def wallet
          @wallet ||= current_accont.wallets.where(address: params[:wallet_id]).or(where(uuid: params[:wallet_id])).first || raise ActiveRecord::RecordNotFound
        end

      end

      resources "wallet/:wallet_id/transactions" do 

        desc "[GET] get transaction collection"
        get do 
          transactions = resource_class_constant.filter(merged_filter_params)
          presenter paginate(wallets)
        end

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

        desc "[GET] get a transaction object by tx_hash or uuid"
        get ":id" do 
          presenter context_resource
        end

      end

    end
  end
end