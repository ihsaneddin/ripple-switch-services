module Admin
  class TransactionsController < AdminController
    
    self.context_resource_class= "Ripples::Models::Transaction"
    self.resource_actions = [:show]
    use_resource!

    def index
      @transactions = Ripples::Models::Transaction.filter(filter_params).page(params[:page]).per(20)
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
        f.js do 
          render_modal
        end
      end
    end

  end
end