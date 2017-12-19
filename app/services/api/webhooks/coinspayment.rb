require 'base64'
require 'openssl'

module Api
  module Webhooks
    class Coinspayment < Base

      COIN_PAYMENTS_IPN_KEY= ENV['COIN_PAYMENTS_IPN_KEY']
      COIN_PAYMENTS_MERCHANT_ID= ENV["COIN_PAYMENTS_MERCHANT_ID"]

      helpers do 

        def verify_webhook data=nil
          unless data
            request.body.rewind
            data = request.body.read
          end
          
          digest  = OpenSSL::Digest.new('sha512')
          
          if coinspayment_header.present?
            calculated_hmac = OpenSSL::HMAC.hexdigest(digest, COIN_PAYMENTS_IPN_KEY, data).strip
            if ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, coinspayment_header) &&  ActiveSupport::SecurityUtils.secure_compare(params[:merchant], COIN_PAYMENTS_MERCHANT_ID)
              block_given?? yield : true
            else
              error!({ error: "Unauthorized!"}, 401)
            end
          else
            error!({ error: "Unauthorized!"}, 401)
          end
        end

        def coinspayment_header
          request.headers['Hmac']
        end

        def subscription txn_id=nil
          Users::Models::Subscription.find_by!(txn_id: txn_id || params[:txn_id] )
        end

        def status_code
          params[:status]
        end

      end

      before do 
        verify_webhook
      end
    
      resources "coinspayment" do 

        post do 
          
          if (status_code < 0)
            subscription.cancel! if subscription.may_cancel?
          elsif (status_code >= 0) && (status_code <= 3)           
            subscription.wait_for_confirmation! if subscription.may_wait_for_confirmation?
          elsif status_code >= 100
            subscription.confirm! if subscription.may_confirm?
          end

          message message: "Ok"
            
        end

      end

    end
  end
end