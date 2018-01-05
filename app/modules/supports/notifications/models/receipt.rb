module Supports
  module Notifications
    module Models
      class Receipt < ApplicationRecord
        
        belongs_to :notification, class_name: "Supports::Notifications::Models::Notification"
        belongs_to :recipient, polymorphic: true

        include Supports::Settingable::Helpers::HasOptions

        include PgSearch
        pg_search_scope :search, associated_against: { notification: { subject: 'A', body: 'B' } }, using: :tsearch

      end
    end
  end
end