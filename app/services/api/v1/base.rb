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
          error!('Unauthorized', 401) unless current_account
        end

        #
        # define current_resource_owner to get current user
        #
        def current_resource_owner
          @current_resource_owner||= Users::Models::Account.where(api_keys).first
        end

        def current_account
          current_resource_owner
        end

      end

      mount Wallets

    end
  end
end