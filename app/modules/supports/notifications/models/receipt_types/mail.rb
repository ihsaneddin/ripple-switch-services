#
# this class is used to push notification to recipient object
# recipient class must implement IPN::Helpers::HasNotifications module and override #ipn_key and #ipn_url methods
#

module Supports
  module Notifications
    module Models
      module ReceiptTypes
        class Mail < Supports::Notifications::Models::Receipt

          has_options fields: { email: nil, subject: nil, :title => nil, body: nil },
                      validations: { 
                                      email: { presence: true }
                                    }

          include AASM

          aasm column: :state do 

            state :scheduled, initial: true
            state :sent

            event :schedule, after: :init_worker do
              transitions from: [:sent], to: :scheduled
            end

            event :invoke do
              transitions from: [:scheduled], to: :sent
            end

          end

          after_create do 
            init_worker
          end

          def init_worker
            Supports::Notifications::Workers::NotificationMailerWorker.perform_async(self.id)
          end

          module Mailer

            extend ActiveSupport::Concern

            def push
              mailer.deliver
              self.invoke if self.may_invoke?
            end

            def mailer
              Supports::Notifications::Mailers::NotificationMailer.notify(self)
            end

          end

          include Supports::Notifications::Models::ReceiptTypes::Mail::Mailer

        end
      end
    end
  end
end