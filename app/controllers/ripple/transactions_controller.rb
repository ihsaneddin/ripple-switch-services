module Ripple
  class TransactionsController < AccountController

    self.context_resource_class= "Ripples::Models::Transaction"
    self.resource_actions = [:new, :create]
    use_resource!

    helper_method :wallet

    include Users::Helpers::TransactionAuthorization::Controller
  
    before_action :authorize_transaction, only: [:create]

    def create
      @transaction.wallet = wallet
      if @transaction.save
        respond_to do |f|
          f.html { redirect_to ripple_wallets_path, notice: "Transaction is submitted" }
          f.js do 
            params[:notification]= { message: "Transaction is submitted" }
            if table_params_present?
              render_table "/shared/table/reload.js.erb"
            end
          end
        end
      else
        respond_to do |f|
          f.html { render :new }
          f.js do 
            if modal_params_present?
              render_modal
            end
          end
        end
      end
    end

    def new
      respond_to do |f|
        f.html
        f.js do 
          if modal_params_present?
            render_modal
          end
        end
      end
    end

    def wallet_class
      Ripples::Models::Wallet
    end

    def wallet
      @wallet ||= wallet_class.where(account: current_account, id: params[:wallet_id])
                  .or(wallet_class.where(account: current_account, encrypted_address: wallet_class.encrypt_address(params[:wallet_id]))).first
    end

    def transaction_params
      if params[:ripples_models_transaction].present?
        params.require(:ripples_models_transaction).permit(:amount, :currency, :destination)
      end
    end

    def complete
      @transaction = resource_class_constant.find_by_tx_hash(params[:id])#wallet.transactions.find_by_tx_hash(params[:id])
      if @transaction
        @transaction.complete! if @transaction.state.blank?
      end
      respond_to do |f|
        f.html{
          redirect_to ripple_wallets_path, notice: "Transaction updated."
        }
        f.js {
          params[:notification]= { message: "Transaction is completed." }
          if table_params_present?
            render_table "/shared/table/reload.js.erb"
          end
        }
      end
    end

  end
end