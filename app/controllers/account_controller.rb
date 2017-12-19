class AccountController < ApplicationController

  before_action :authenticate_account!

  layout 'account'

  include ModalViewHelper::Concern, Resources, TableViewHelper::Concern

  helper_method :filter_params

  def filter_params
    params[:filter] || {}
  end

  def subscribing?
    if current_account.draft_subscription.present?
      redirect_to plan_subscription_path(current_account.draft_subscription.plan.name, current_account.draft_subscription.name)
    end
  end

end
