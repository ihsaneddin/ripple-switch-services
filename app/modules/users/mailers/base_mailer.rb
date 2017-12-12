module Users
  module Mailers
    class BaseMailer < ActionMailer::Base
      
      include Rails.application.routes.url_helpers

      default :from => 'RSS <no-reply@rss.com>'

      append_view_path Rails.root.join('app', 'modules', 'users', 'views', 'mailers')
    
    end
  end
end