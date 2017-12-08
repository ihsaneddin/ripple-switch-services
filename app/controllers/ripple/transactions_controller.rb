module Ripple
  class TransactionsController < AccountController

    self.context_resource_class= "Ripples::Models::Transaction"
    self.resource_actions = [:new, :create]
    use_resource!

    helper_method :wallet
  
    def create
      @transaction.wallet = wallet
      if @transaction.save
        respond_to do |f|
          f.html { redirect_to ripple_wallets_path, notice: "Transaction is submitted" }
          f.js do 
            params[:notification]= { message: "Transaction is submitted" }
            render_table "/shared/table/reload.js.erb"
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

    def wallet
      @wallet ||= Ripples::Models::Wallet.where(account: current_account).find params[:wallet_id]
    end

    def transaction_params
      if params[:ripples_models_transaction].present?
        params.require(:ripples_models_transaction).permit(:amount, :currency, :destination)
      end
    end

  end
end