module Admin
  class SubscriptionsController < AdminController
    
    self.context_resource_class= "Users::Models::Subscription"
    self.identifier = :name
    self.find_by = :name
    self.resource_actions = [:show, :cancel, :confirm, :expire]
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

    def cancel
      if @subscription.cancel!
        message="Subscription is now canceled"
        respond_to do |f|
          f.html{ 
            flash[:notice]= message
            redirect_back(fallback_location: root_path)
          }
          f.js do 
            params[:notification]= { message: message }
            render_table "/shared/table/reload.js.erb" if table_params_present?
            render_modal if modal_params_present?
          end
        end
      end
    end

    def confirm
      if @subscription.confirm!
        message="Subscription is now activated"
        respond_to do |f|
          f.html{ 
            flash[:notice]= message
            redirect_back(fallback_location: root_path) 
          }
          f.js do 
            params[:notification]= { message: message }
            render_table "/shared/table/reload.js.erb" if table_params_present?
            render_modal if modal_params_present?
          end
        end
      end
    end

    def expire
      if @subscription.expire!
        message="Subscription is now expired"
        respond_to do |f|
          f.html{ 
            flash[:notice]= message
            redirect_back(fallback_location: root_path)
          }
          f.js do 
            params[:notification]= { message: message }
            
            render_table "/shared/table/reload.js.erb" if table_params_present?
            render_modal if modal_params_present?
          end
        end
      end
    end

  end
end