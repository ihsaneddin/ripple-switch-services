module Admin
  class DashboardsController < AdminController
  
    def index
      
    end

    def accounts
      render json: Users::Models::Account.group_by_month(:created_at, last: 12).count
    end

    def wallets
      
    end

    def subscriptions
      render json: Users::Models::Subscription.joins(:plan).group("users_plans.name").group_by_month("users_subscriptions.created_at", last: 12).count.chart_json

    end

    def transactions
      
    end

  end
end