module Supports
  module Notifications
    module Models
      class Receipt < ApplicationRecord
        
        belongs_to :notification, class_name: "Supports::Notifications::Models::Notification"
        belongs_to :recipient, polymorphic: true

        include Supports::Settingable::Helpers::HasOptions

      end
    end
  end
end