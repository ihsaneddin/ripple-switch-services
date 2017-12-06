class AccountController < ApplicationController

  before_action :authenticate_account!

  layout 'account'

  include ModalViewHelper::Concern, Resources, TableViewHelper::Concern

  helper_method :filter_params

  def filter_params
    params[:filter] || {}
  end

end
