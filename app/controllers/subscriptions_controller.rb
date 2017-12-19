class SubscriptionsController < AccountController

  before_action :subscribing?, except: :show

  self.resource_actions = [:new, :create, :show]
  self.identifier = :name
  self.find_by = :name
  use_resource!

  helper_method :plan, :plan_rates

  def new
    @subscription.plan = plan
    respond_to do |f|
      f.html
      f.js
    end
  end

  def create
    if current_account.active_plan.could_be_upgraded_to?(plan)
      @subscription.plan= plan
      if @subscription.save
        respond_to do |f|
          f.html{ redirect_to plan_subscription_path(plan.name, @subscription.name) }
        end
      else
        respond_to do |f|
          f.html { render :new }
        end
      end
    else
      redirect_to plans_path, error: "Can not upgraded"
    end
  end

  def show
    
  end

  def cancel
    begin 
      if @subscription.cancel!
        respond_to do |f|
          f.html{ redirect_to plan_path, :notice => "Subscription is cancelled" }
        end
      end
    rescue AASM::InvalidTransition => e
      redirect_to plan_subscription_path(plan.name, subscription.name), error: "Can not cancel subscription."
    end
  end

  def resource_class_constant
    current_account.subscriptions
  end

  def subscription_params
    params[:users_models_subscription].present?? params.require(:users_models_subscription).permit(:coin) : {}
  end

  protected

    def plan
      @plan ||= Users::Models::Plan.cached_collection.find_by_name(params[:plan_name])
      @plan.present?? @plan : raise(ActiveRecord::RecordNotFound)
    end

    def plan_rates
      @plan_rates||= Users::Models::Plan.plan_rates
    end

end