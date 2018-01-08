#
# this class is used to push notification to recipient object
# recipient class must implement IPN::Helpers::HasNotifications module and override #ipn_key and #ipn_url methods
#

module Supports
  module Notifications
    module Models
      module ReceiptTypes
        class Mail < Supports::Notifications::Models::Receipt

          has_options fields: { email: nil, subject: nil, :title => nil, body: nil, :template_name => nil, template_path: nil, append_view_path: nil, push_immediately: false },
                      validations: {
                                      email: { presence: true }
                                    }

          include AASM

          attr_accessor :mailer_options

          after_initialize do
            self.mailer_options||= {}
          end

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
            init_worker_or_deliver_immediately
          end

          def init_worker_or_deliver_immediately
            if option_push_immediately
              self.push
            else
              Rails.env.development?? Supports::Notifications::Workers::NotificationMailerWorker.new.perform(self.id) : Supports::Notifications::Workers::NotificationMailerWorker.perform_async(self.id)
            end
          end

          def mail_template
            Pathname.new ["#{option_append_view_path}", "#{option_template_path}", "#{option_template_name}"].compact.join('/')
          end

          module Mailer

            extend ActiveSupport::Concern

            def push
              mailer.deliver
              self.invoke if self.may_invoke?
            end

            def mailer
              Supports::Notifications::Mailers::NotificationMailer.notify(self, mailer_options)
            end

          end

          include Supports::Notifications::Models::ReceiptTypes::Mail::Mailer

        end
      end
    end
  end
end