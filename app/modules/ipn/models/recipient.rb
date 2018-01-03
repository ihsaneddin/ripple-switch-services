#
# this class is used to push notification to recipient object
# recipient class must implement IPN::Helpers::HasNotifications module and override #ipn_key and #ipn_url methods
#
require 'connection/request'
require 'base64'
require 'openssl'

module IPN
  module Models
    class Recipient < ApplicationRecord
      
      belongs_to :notification, class_name: "IPN::Models::Notification"
      belongs_to :recipient, polymorphic: true

      include AASM

      aasm column: :state do 

        state :scheduled, initial: true
        state :sent
        state :retried
        state :failed

        event :invoke do 
          transitions from: [:scheduled, :retried], to: :sent
        end

        event :push_again, after: :retry_push do 
          transitions from: [:scheduled], to: :retried
        end

        event :schedule, after: :init_worker do 
          transitions from: [:retried], to: :scheduled
        end

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
        IPN::Workers::PushNotificationWorker.perform_at(from + 1.minute, self.id)
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
        self.retry_count >= self.retry
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
            if notification.serializer_class.present?
              @serialized_attrs||= notification.serializer_class.constantize.new(notification.notifiable)
            else
              @serialized_attrs||= { title: notification.title, message: notification.message }.merge!(notification.notifiable.attributes)
            end
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
            recipient.ipn_key
          end

          #
          # get recipient ipn_url
          #
          def recipient_ipn_url
            recipient.ipn_url
          end

      end

      include IPN::Models::Recipient::Request

    end
  end
end