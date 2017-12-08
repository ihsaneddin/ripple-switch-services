module Api
  module V1
    class Transactions < Api::V1::Base
      

      self.presenter_name= "Transaction"
      self.context_resource_class= 'Ripples::Models::Transaction'

      use_resource!

      helpers do 

        def transaction_params
          posts[:transaction] = posts
          posts.require(:transaction).permit!(:amount, :destination)
        end

        def transaction_by_hash_or_id
          @transaction ||= resource_class_constant.where(id: params[:id]).or(resource_class_constant.where(tx_hash: params[:id])).first
        end

      end

      resources "wallets" do 

        desc "[POST] create a new transaction"
        post do 
          if context_resource.save
            presenter context_resource
          else
            standard_validation_error details: context_resource.errors
          end
        end

        desc "[GET] check transactions status"
        get ":id" do 
          transaction_by_hash_or_id
        end

      end


    end
  end
end