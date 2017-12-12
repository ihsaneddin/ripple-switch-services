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

        def transaction_by_hash_or_id
          @transaction ||= resource_class_constant.where(id: params[:id]).or(resource_class_constant.where(tx_hash: params[:id])).first
        end

      end

      resources "wallet/:wallet_id/transactions" do 

        desc "[GET] get transaction collection"
        get do 
          
        end

        desc "[POST] create a new transaction"
        post do 
          authorize_transaction do
            if context_resource.save
              presenter context_resource
            else
              standard_validation_error details: context_resource.errors
            end
          end
        end

        desc "[GET] check transactions status by tx_hash"
        get ":id" do 
          
        end

      end


    end
  end
end