module Api
  module V1
    class Wallets < Api::V1::Base
      

      self.presenter_name= "Wallet"
      self.context_resource_class= 'Ripples::Models::Wallet'

      use_resource!

      helpers do 

        def wallet_params
          posts[:wallet] = posts
          posts.require(:wallet).permit!(:label)
        end

        def existing_resource_finder
          resource_class_constant.where(id: params[:id]).or(resource_class_constant.where(label: params[:id])).first
        end

      end

      resources "wallets" do 
        
        desc "[GET] index all current_account wallets"
        get do
          wallets = resource_class_constant.filter(filter_params).where(account: current_account)
          presenter paginate(wallets)
        end

        desc "[POST] create a new wallet address"
        post do 
          if context_resource.save
            presenter context_resource
          else
            standard_validation_error details: context_resource.errors
          end
        end

        desc "[GET] get a wallet by uuid or label"
        get ':id' do 
          presenter context_resource
        end

        desc "[DELETE] archive a wallet by label or uuid"
        delete ":id" do 
          if context_resource.destroy
            presenter context_resource
          end
        end

        desc "[PUT] restore a wallet by label or address or uuid"
        put ":id/restore" do 
          context_resource= resource_class_constant.only_deleted.where(id: params[:id]).or(resource_class_constant.only_deleted.where(label: params[:id])).or(resource_class_constant.only_deleted.where(encrypted_address: resource_class_constant.encrypt_address(params[:id]))).first
          context_resource.restore
          presenter context_resource
        end

      end


    end
  end
end