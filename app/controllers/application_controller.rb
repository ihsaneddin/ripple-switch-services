class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  helper_method :devise_resource

  layout :user_layout

  include NotificationViewHelper::Concern

  rescue_from AASM::InvalidTransition do |e|
    message = e.message.html_safe
    respond_to do |f|
      f.html do
        flash[:error]= message
        redirect_back(fallback_location: root_path)
      end
      f.js do
        params[:notification]= { message: message, type: "danger" }
        render_notification
      end
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    respond_to do |f|
      f.html do
        flash[:error]= "Page not found!"
        redirect_to root_path
      end
    end
  end

  def devise_resource(klass= Users::Models::Account)
    @resource ||= params[:id].present?? klass.find(params[:id]) : klass.new
  end

  def user_layout
    current_account.present?? 'account' : 'landing'
  end

  def previous_page
    request.env['HTTP_REFERER']
  end

end
