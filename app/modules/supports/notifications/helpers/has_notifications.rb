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
            @notifications = Supports::Notifications::Models::Notification.filter(filter_params).desc.recipient(recipient).page(params[:page]).per(params[:per_page] || 20)
            respond_to do |f|
              f.html{}
              f.js{}
              f.json{}
            end
          end

          def read

          end

          def trash

          end

          def untrash

          end

          protected

            def recipient
              try(:current_account)
            end

            def filter_params
              params[:filter] || {}
            end

        end

      end
    end
  end
end