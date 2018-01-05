#
# this class is represent a common notification object
#

module Supports
  module Notifications
    module Models
      module ReceiptTypes
        class Common < Supports::Notifications::Models::Receipt

          has_options fields: { broadcast: false }

          after_create do 
            init_worker if option_broadcast
          end

          def init_worker
            Supports::Notifications::Workers::BroadcastWorker.perform_async(self.id)
          end
  
          def read!
            update is_read: true
          end 

          def trash!
            update is_trashed: true
          end

          def untrash!
            update is_trashed: false
          end

          def move(mailbox_name)
            update mailbox_type: mailbox_name
          end

          def push
            ActionCable.server.broadcast "notification-#{recipient_type.to_s.demodulize.downcase.parameterize.underscore}-#{recipient_id}",
                                          message: 
                                                  { 
                                                    subject: notification.subject,
                                                    body: notification.body,
                                                    is_read: is_read,
                                                    is_trashed: is_trashed,
                                                    created_at: created_at,
                                                    updated_at: updated_at
                                                  }.to_json
          end

        end
      end
    end
  end
end