module NotificationViewHelper

  module Concern
      
    extend ActiveSupport::Concern

    included do 
      helper_method :notification_params
    end

    def render_notification
      if notification_params.present?
        render file: "/shared/notification/notification.js.erb", locals: notification_params
      else
        yield if block_given?
      end
    end

    def notification_params
      params[:notification] || {}
    end
  end

end