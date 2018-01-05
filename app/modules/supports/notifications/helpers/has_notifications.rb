module Supports
  module Notifications
    module Helpers
      module HasNotifications
        
        extend ActiveSupport::Concern

        module Models
          extend ActiveSupport::Concern

          module ClassMethods

            def has_notifications
              has_many :receipts, as: :recipient, class_name: "Supports::Notifications::Models::Receipt"
              has_many :notifications, through: :receipts, source: :notification, class_name: "Supports::Notifications::Models::Notification"
              has_many :ipn_receipts, as: :recipient, class_name: "Supports::Notifications::Models::ReceiptTypes::IPN"
              has_many :mail_receipts, as: :recipient,class_name: "Supports::Notifications::Models::ReceiptTypes::Mail"
              has_many :common_receipts, as: :recipient, class_name: "Supports::Notifications::Models::ReceiptTypes::Common"
            end

          end

        end

        module Controllers
          extend ActiveSupport::Concern

          def index
            
          end

          def read
            
          end

          def trash
            
          end

          def untrash
            
          end

        end

      end
    end
  end
end