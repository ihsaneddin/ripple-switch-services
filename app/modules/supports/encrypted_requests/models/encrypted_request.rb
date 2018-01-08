#
# encrypt sensitive data using ActiveSupport::MessageEncryptor
#
module Supports
  module EncryptedRequests
    module Models
      class EncryptedRequest < ApplicationRecord

        belongs_to :requester, polymorphic: true
        belongs_to :context, polymorphic: true

        include AASM
        aasm column: :state do

          state :available, initial: true
          state :expired

          event :expiry, after: :expiring! do
            transitions from: :available, to: :expired
          end

        end

        include Supports::Notifications::Helpers::Notify
        notify recipients: :requester,
               on: :after_commit,
               if: :notify?,
               subject: :notification_subject,
               mail: {
                        option_email: Proc.new{|rec| rec.email },
                        option_template_name: "encrypted_request",
                        option_append_view_path: Rails.root.join('app', 'modules', 'supports', 'encrypted_requests', "views").to_s,
                        option_template_path: "mailers",
                        option_push_immediately: true,
                        mailer_options: :mailer_options
                      }

        def notification_subject
          case context_type.to_s.demodulize.downcase.underscore
          when 'wallet'
            "Export Wallet's Secret Request"
          end
        end

        def notify?
          created_at == updated_at
        end

        def expiring!
          update encrypted_data: nil
        end

        module EncryptAttribute

          extend ActiveSupport::Concern

          included do

            attr_accessor :given_key, :given_salt, :generated_key, :given_data, :given_notification_subject

            before_create do
              _encrypt_
              set_expired_at
            end

          end

          def mailer_options
            {given_salt: given_salt}
          end

          def _encrypt_
            self.encrypted_data = crypt.encrypt_and_sign(given_data)
          end

          def set_expired_at
            self.expired_at||= DateTime.now + 5.minutes
          end

          def is_expired?
            #expiry! if expired_at < DateTime.now
          end

          def decrypt(opts={})
            is_expired?
            decrypted_data = nil
            unless expired?
              decrypted_data= crypt(opts).decrypt_and_verify(self.encrypted_data) rescue nil
              expiry!
            end
            decrypted_data
          end

          def crypt opts={}
            return @crypt if @crypt
            opts= { given_key: given_key, given_salt: given_salt }.merge(opts)
            generated_key= ActiveSupport::KeyGenerator.new(opts[:given_key]).generate_key(opts[:given_salt], 32)
            @crypt = ActiveSupport::MessageEncryptor.new(generated_key)
          end

        end

        include Supports::EncryptedRequests::Models::EncryptedRequest::EncryptAttribute

      end
    end
  end
end