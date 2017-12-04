#
# @Override Doorkeeper::ApplicationMetalController
# to provide specific authorization scenario 
# this class should be provide grant password scenario only!
# TODO : change all message text to Int.
#

module Api
  class SessionsController < ::Doorkeeper::ApplicationMetalController

    RESOURCEOWNERCLASS= Users::Models::Account
    
    # include exception handlers module
    # include ::ExceptionHandlers::Rails::Responses
   
    #
    # [POST] /api/v1/sessions
    # @Override ::Doorkeeper::TokensController#token
    # this method should be enough to generate token
    #
    def create
      response = authorize_response
      headers.merge! response.headers
      if response.status == :ok
        self.status        = response.status
        self.response_body = response_body(response)
      else
        raise ::Doorkeeper::Errors::DoorkeeperError
      end
    rescue ::Doorkeeper::Errors::DoorkeeperError => e
      self.status = :unauthorized
      self.response_body = { message: "Invalid username or password" }.to_json
    end

    #
    # [DELETE] /api/v1/sessions
    # @Override ::Doorkeeper::Tokens::Controller#revoke
    #
    def destroy
      if authorized?
        revoke_token
      end
      render json: { message: "Token is revoked!" }, status: 200
    end

    protected

      #
      # get current resource token owner
      #
      def current_resource_owner(resource_owner_id=nil)
        @current_resource_owner||= RESOURCEOWNERCLASS.find(resource_owner_id)
      end

      def response_body(response)
        resource_serializer = ::Main::UsersManagement::Serializers::UserSerializer.new(current_resource_owner(response.token.resource_owner_id))
        response_body= response.body.merge!({ resource_owner: user_serializer.to_h }).to_json
      end

  end
end
