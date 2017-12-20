module Admin
  class SubscriptionsController < AdminController
    
    self.context_resource_class= "Users::Models::Subscription"
    self.identifier = :name
    self.find_by = :name
    use_resource!

    def index
      @subscriptions = Users::Models::Subscription.filter(filter_params).page(params[:page]).per(params[:per_page] || 20)
      respond_to do |f|
        f.html
        f.js do 
          render_table if table_params_present?
        end
      end
    end

    def show
      respond_to do |f|
        f.html
        f.js do 
          render_modal if modal_params_present?
        end
      end
    end

  end
end