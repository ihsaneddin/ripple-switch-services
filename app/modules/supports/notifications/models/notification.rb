module Supports
  module Notifications
    module Models
      class Notification < ApplicationRecord

        belongs_to :notifiable, :polymorphic => true
        belongs_to :sender, polymorphic: true, optional: true
        has_many :receipts, class_name: "Supports::Notifications::Models::Receipt", dependent: :destroy
        has_many :ipns, class_name: "Supports::Notifications::Models::ReceiptTypes::IPN", dependent: :destroy
        has_many :commons, class_name: "Supports::Notifications::Models::ReceiptTypes::Common", dependent: :destroy
        has_many :mails, class_name: "Supports::Notifications::Models::ReceiptTypes::Mail", dependent: :destroy

        module Common

          extend ActiveSupport::Concern

          included do

            scope :recipient, lambda { |recipient|
                                      joins(:commons).where(:commons => { :recipient_id  => recipient.id, :recipient_type => recipient.class.name })
                                   }
            scope :with_object, lambda { |obj|
                                          where(:notified_object_id => obj.id, :notified_object_type => obj.class.to_s)
                                       }
            scope :not_trashed, lambda {
                                        joins(:commons).where(commons: { is_trashed: false })
                                      }
            scope :unread, lambda {
                                    joins(:commons).where(commons: { is_read: false })
                                  }
            scope :read, lambda {
                                  joins(:commons).where(commons: { is_read: true })
                                }

          end

          module ClassMethods

            def filter(params={})
              res = cached_collection
              if params[:unread].present?
                res = res.unread
              end
              if params[:read].present?
                res = res.read
              end
              res
            end

          end

        end

        include Supports::Notifications::Models::Notification::Common

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