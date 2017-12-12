class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :exception

  helper_method :devise_resource

  layout :user_layout

  def devise_resource(klass= Users::Models::Account)
    @resource ||= params[:id].present?? klass.find(params[:id]) : klass.new
  end

  def user_layout
    current_account.present?? 'account' : 'landing' 
  end


end
