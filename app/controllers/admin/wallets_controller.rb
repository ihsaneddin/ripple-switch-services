module Admin
  class WalletsController < AdminController

    self.context_resource_class= "Ripples::Models::Wallet"
    self.resource_actions = [:show]
    use_resource!
  
    def index
      @wallets = Ripples::Models::Wallet.filter(filter_params.merge!(archived: params[:archived])).page(params[:page]).per(20)
      respond_to do |f|
        f.html
        f.js do 
          render_table
        end
      end
    end

    def show
      respond_to do |f|
        f.html
        f.js {
          if modal_params_present?
            render_modal
          end
        }
      end
    end

  end
end