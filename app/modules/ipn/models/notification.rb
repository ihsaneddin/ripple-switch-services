require 'connection/request'

module IPN
  module Models
    class Notification < ApplicationRecord
      
      belongs_to :notifiable, :polymorphic => true
      has_many :recipients, class_name: "IPN::Models::Recipient", dependent: :destroy

      attr_accessor :recipients_list, :retry

      #
      # set retry integer to recipients object
      # and insert recipients object to #recipients collection
      #
      before_validation do 
        set_retry
        insert_recipients_list
      end

      #
      # insert retry integer to recipient object
      #
      def set_retry
        if recipients_list.is_a?(Array)
          recipients_list.each{|recipient| recipient.retry= self.retry }
        end
      end

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