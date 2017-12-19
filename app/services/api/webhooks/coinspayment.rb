require 'base64'
require 'openssl'

module Api
  module Webhooks
    class Coinspayment < Base

      COIN_PAYMENTS_IPN_KEY= ENV['COIN_PAYMENTS_IPN_KEY']

      helpers do 

        def verify_webhook data
          digest  = OpenSSL::Digest.new('sha256')
          logger.info("#{request.headers}\n")
          logger.info("#{data}\n")
          if coinspayment_header.present?
            calculated_hmac = Base64.encode64(OpenSSL::HMAC.hexdigest(digest, COIN_PAYMENTS_IPN_KEY, data)).strip
            if ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, coinspayment_header)
              yield
            end
          else
            logger.info ("Not Verified\n")
          end
        end

        def coinspayment_header
          request.headers['Hmac']
        end

      end
    
      resources "coinspayment" do 

        post do 
          logger.info("++++ START COINSPAYMENT APN ++++\n")
          request.body.rewind
          data = request.body.read
          verify_webhook(data) do 
            logger.info "Verified"
            logger.info data  
          end
          logger.info("++++ END COINSPAYMENT APN ++++\n")
        end

      end

    end
  end
end