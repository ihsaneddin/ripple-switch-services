module Supports
  module Notifications
    module Mailers
      class BaseMailer < ActionMailer::Base

        include Rails.application.routes.url_helpers

        default form: "Rss <no-reply@rss.com>"

        append_view_path Rails.root.join("app", "modules", "supports", "notifications", "views", "mailers")

      end
    end
  end
end