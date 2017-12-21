module Admin
  class PlansController < AdminController

    self.context_resource_class= "Users::Models::Plan"
    self.identifier = :name
    self.find_by = :name
    self.resource_actions = [:new, :create, :edit, :update, :show, :destroy, :activate, :deactivate]
    use_resource!

    helper_method :plan_states
    
    def index
      @plans = Users::Models::Plan.cached_collection.filter(filter_params).page(params[:page]).per(params[:per_page] || 2)
      respond_to do |f|
        f.html
        f.js do 
          render_table if table_params_present?
        end
      end
    end

    def show
      @plan_subscriptions = @plan.subscriptions.page(1).per(20)
      respond_to do |f|
        f.html
        f.js
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

    def create
      if @plan.save
        #@plan.reorder_position
        message = "New package is successfully created!"
        respond_to do |f|
          f.html { redirect_to admin_plans_path, notice: "Success" }
          f.js do 
            params[:notification]= { message: message }
            render_table "/shared/table/reload.js.erb"
          end
        end
      else
        respond_to do |f|
          f.html { render :new }
          f.js do 
            if modal_params_present?
              params[:notification]= { message: "Failed to create new package!", type: "danger" }
              render_modal
            end
          end
        end
      end
    end

    def edit
      respond_to do |f|
        f.html
        f.js {
          render_modal if modal_params_present?
        }
      end
    end

    def update
      if @plan.update plan_params
        @plan.reorder_position
        message = "Package #{@plan.name} is successfully updated!"
        respond_to do |f|
           f.html { redirect_to admin_plans_path, notice: message }
          f.js do 
            params[:notification]= { message: message }
            render_table "/shared/table/reload.js.erb"
          end
        end
      else
        respond_to do |f|
          f.html { render :new }
          f.js do 
            if modal_params_present?
              params[:notification]= { message: "Failed to create update #{@plan.name} package!", type: "danger" }
              render_modal
            end
          end
        end
      end
    end

    def destroy
      if @plan.destroy
        respond_to do |f|
          f.html { redirect_to admin_plans_path, notice: "Package is archived!" }
          f.js do 
            if table_params_present?
              params[:notification]= { message: "Package #{@plan.name} is sent to archive" }
              render_table "/shared/table/reload.js.erb"
            end
          end
        end
      end
    end

    def activate
      if @plan.activate!
        message= "Package #{@plan.name} is activated"
        respond_to do |f|
          f.html { redirect_to admin_plans_path, notice: message }
          f.js do 
            if table_params_present?
              params[:notification]= { message: message }
              render_table "/shared/table/reload.js.erb"
            end
          end
        end
      end
    end

    def deactivate
      if @plan.deactivate!
        message= "Package #{@plan.name} is deactivated"
        respond_to do |f|
          f.html { redirect_to admin_plans_path, notice: message }
          f.js do 
            if table_params_present?
              params[:notification]= { message: message }
              render_table "/shared/table/reload.js.erb"
            end
          end
        end
      end
    end

    def restore
      if resource_class_constant.restore(params[:id])
        respond_to do |f|
          f.html{ redirect_to ripple_wallets_path(archived: true), notice: "Package is restored" }
          f.js do 
            if table_params_present?
              params[:notification]= { message: "Package restored!" }
              render_table "/shared/table/reload.js.erb"
            end
          end
        end
      else
      end
    end

    def plan_params
      if params[:users_models_plan].present?
        params.require(:users_models_plan).permit(:name, :display_order, :price, :free, :description, :features => [ :max_wallets_count, :max_api_request_per_second ])
      end
    end

    protected

      def plan_states
        resource_class_constant.aasm.states.map(&:name).map{|state| state.to_s.humanize }
      end

  end
end