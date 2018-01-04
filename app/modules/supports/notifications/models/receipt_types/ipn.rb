#
# this class is used to push instant payment notification based on `option_ipn_key` and `option_ipn_url`
#
require 'connection/request'
require 'base64'
require 'openssl'

module Supports
  module Notifications
    module Models
      module ReceiptTypes
        class IPN < Supports::Notifications::Models::Receipt

          has_options fields: { ipn_key: nil, ipn_url: nil, retry: 5, retry_count: 0 },
                      validations: { 
                                      ipn_key: { presence: true, length: { minimum: 10 } }, 
                                      ipn_url: { presence: true, url: true }
                                    } 

          include AASM

          aasm column: :state do 

            # initial state, after the object created, it will push worker to send notification to #recipient_ipn_url
            state :scheduled, initial: true

            # this state indicates that the notification is successfully sent to #recipient_ipn_url
            state :sent
            
            # this state indicates that notification is being retried 
            state :retried

            # this state indicats that push notification is failed after retried based on #can_still_retry?
            state :failed

            # event to change state to `sent` 
            event :invoke do 
              transitions from: [:scheduled, :retried], to: :sent
            end

            # this event is used to retry failed push notification
            event :push_again, after: :retry_push do 
              transitions from: [:scheduled], to: :retried
            end

            # this event is used to initialize push_notification_worker
            event :schedule, after: :init_worker do 
              transitions from: [:retried], to: :scheduled
            end

            # this event is used to indicate the notification is failed to send
            event :fail do 
              transitions from: [:scheduled, :retried], to: :failed
            end

          end

          #
          # init worker after the object is created
          #
          after_create do 
            init_worker
          end

          #
          # start worker to push notification at 1 minute from DateTime.now
          #
          def init_worker(from= DateTime.now)
            Supports::Notifications::Workers::InstantPaymentNotificationWorker.perform_at(from + 1.minute, self.id)
          end

          #
          # this callback is called after aasm #retry event
          #
          def retry_push
            self.update_attribute :retry_count, self.retry_count + 1
            self.schedule!
          end

          #
          # check if the object can still push
          #
          def still_can_retry?
            self.option_retry_count.to_i >= self.option_retry.to_i
          end

          module Request

            extend ActiveSupport::Concern

            #
            # push notification to #recipient_ipn_url
            # if not succeed then reinit the worker if #still_can_retry?
            #
            def push
              request([:post, recipient_ipn_url, { params: prepend_params, header: prepend_header }])
              count= 0
              while(count < 5) do 
                count = count + 1
                request.invoke
                if request.success?
                  self.invoke!
                  break
                end
              end
              
              unless self.sent?
                if self.still_can_retry?
                  self.fail!
                else
                  self.push_again!
                end
              end
            end

            private

              #
              # prepare header for request
              #
              def prepend_header
                {
                  'Content-Type' =>'application/json', 
                  "Accept" => "application/json",
                  "HTTP_X_RSS_HMAC_SHA512" => calculate_hmac
                }
              end

              #
              # prepare the params for request
              #
              def prepend_params
                @params||= serialized_attrs 
              end

              #
              # get params for request
              # if notification#serializer_class is present then use standard params
              #
              def serialized_attrs
                if option_serializer_class.present?
                  @serialized_attrs||= option_serializer_class.constantize.new(notification.notifiable).serializable_hash rescue nil
                end
                @serialized_attrs||= { title: notification.title, message: notification.message }.merge!(notification.notifiable.attributes)
              end

              #
              # get hmac string for the request header
              # use 512 bit string encryption
              #
              def calculate_hmac
                form = serialized_attrs.to_json #URI.escape(serialized_attrs.collect{|k,v| "#{k}=#{v}"}.join('&'))
                @hmac||= OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha512'), recipient_ipn_key, form).strip
              end
              
              #
              # set Connection::Request object
              #
              def request(options= [])
                @request||= Connection::Request.new *options
              end

              #
              # get recipient ipn_key to hmac calculation
              #
              def recipient_ipn_key
                option_ipn_key
              end

              #
              # get recipient ipn_url
              #
              def recipient_ipn_url
                option_ipn_url
              end

          end

          include Supports::Notifications::Models::ReceiptTypes::IPN::Request

        end
      end
    end
  end
end