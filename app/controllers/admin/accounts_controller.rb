module Admin 
  class AccountsController < AdminController
    
    self.context_resource_class= "Users::Models::Account"
    self.resource_actions = [:show]
    self.identifier = :username
    self.find_by = :username
    use_resource!

    helper_method :plans

    def index
      @accounts = Users::Models::Account.filter(filter_params).page(params[:page]).per(params[:per_page] || 20)
      respond_to do |f|
        f.html{}
        f.js do
          if table_params_present?
            render_table
          end
        end
      end
    end

    def show
      respond_to do |f|
        f.html {}
        f.js do
          if modal_params_present?
            render_modal
          end
        end
      end
    end

    protected

      def plans
        @plans||= Users::Models::Plan.cached_collection#.active
      end

  end
end