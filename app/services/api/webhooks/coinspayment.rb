require 'base64'
require 'openssl'

module Api
  module Webhooks
    class Coinspayment < Base

      COIN_PAYMENTS_IPN_KEY= ENV['COIN_PAYMENTS_IPN_KEY']
      COIN_PAYMENTS_MERCHANT_ID= ENV["COIN_PAYMENTS_MERCHANT_ID"]

      helpers do 

        def verify_webhook data
          digest  = OpenSSL::Digest.new('sha512')
          logger.info("#{request.headers}\n")
          logger.info("#{data}\n")
          if coinspayment_header.present?
            calculated_hmac = OpenSSL::HMAC.hexdigest(digest, COIN_PAYMENTS_IPN_KEY, data).strip
            if ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, coinspayment_header) &&  ActiveSupport::SecurityUtils.secure_compare(params[:merchant], COIN_PAYMENTS_MERCHANT_ID)
              block_given?? yield : true
            end
          else
            logger.info ("Not Verified\n")
          end
        end

        def coinspayment_header
          request.headers['Hmac']
        end

        def subscription txn_id=nil
          @txn_id||= Users::Models::Subscription.find_by_txn_id(txn_id)
        end

      end

      before do 
        verify_webhook
      end
    
      resources "coinspayment" do 

        post do 
          logger.info("++++ START COINSPAYMENT APN ++++\n")
          request.body.rewind
          data = request.body.read
          verify_webhook(data) do 

          end
          logger.info("++++ END COINSPAYMENT APN ++++\n")
        end

      end

    end
  end
end