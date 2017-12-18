module Api
  module V1
    class Base < ::Api::Base
    
      include Concerns::GrapeResources

      version "v1", using: :path

      #
      # protect endpoints with doorkeeper
      #
      before do
        authorize! unless skip_authorization
      end

      helpers do 

        def skip_authorization;end

        def api_keys
          {
            token: params[:api_key],
            username: params[:api_username]
          }
        end

        def authorize!
          error!('Unauthorized', 401) unless authenticated
        end

        def warden
          env['warden']
        end

        def authenticated
          @current_resource_owner||= Users::Models::Account.cached_collection.where(api_keys).first
          warden.set_user(@current_resource_owner, scope: :account) if @current_resource_owner
          return true if warden.authenticated?
        end

        def current_account
          warden.user || @current_resource_owner
        end

      end

      mount Wallets
      mount Transactions

    end
  end
end