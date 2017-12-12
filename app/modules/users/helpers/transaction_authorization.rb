module Users
  module Helpers
    module TransactionAuthorization

      module Controller

        extend ActiveSupport::Concern

        def authorize_transaction options={}
          pin = options[:pin] || params[:pin]
          if current_account.pin.eql?(pin)
            yield if block_given?
          else
            respond_to do |f|
              f.html{ redirect_to request.env['HTTP_REFERER'], error: "Unauthorized!" }
              f.js{
                params[:notification]= { message: "Wrong secret PIN!", type: "error" }
                if params[:modal]
                  render_modal
                end
              }
            end
          end
        end

      end

      module Grape

        extend ActiveSupport::Concern

        module HelperMethods

          def authorize_transaction options={}
            pin = options[:pin] || params[:pin]
            if Users::Models::Account.find_by(encrypted_pin: Users::Models::Account.encrypt_pin(pin))
              yield if block_given?
            else
              error!('Wrong secret PIN', 401)
            end
          end

        end

      end

    end
  end
end