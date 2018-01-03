module IPN
  module Helpers
    module HasNotifications
      
      extend ActiveSupport::Concern

      #
      # this method must be implemented for recipient#recipient object
      #
      def ipn_key
        raise "Must be implemented"
      end

      #
      # this method must be implemented for recipient#recipient object
      #
      def ipn_url
        raise "Must be implemented"
      end

      module ClassMethods

        #
        # append necessary relation methods 
        #
        def has_notifications
          has_many :recipients, as: :recipient, class_name: "IPN::Models::Recipient"
          has_many :notifications, through: :recipients, source: :recipient, source_type: "#{self.name}", class_name: "IPN::Models::Notification" 
        end

      end

    end
  end
end