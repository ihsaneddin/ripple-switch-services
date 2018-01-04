module Supports
  module Notifications
    module Models
      class Notification < ApplicationRecord

        belongs_to :notifiable, :polymorphic => true
        has_many :receipts, class_name: "Supports::Notifications::Models::Receipt", dependent: :destroy
        has_many :ipns, class_name: "Supports::Notifications::Models::ReceiptTypes::IPN", dependent: :destroy
        has_many :commons, class_name: "Supports::Notifications::Models::ReceiptTypes::Common", dependent: :destroy
        has_many :mails, class_name: "Supports::Notifications::Models::ReceiptTypes::Mail", dependent: :destroy

        attr_accessor :recipients_list

        #
        # insert recipients list
        #
        def insert_recipients_list
          recipients_list = recipients_list.is_a?(Array) ? recipients_list : Array(recipients_list)
          recipients_list.uniq.compact.each {|recipient| self.recipients << recipient }
          recipients_list
        end

      end
    end
  end
end