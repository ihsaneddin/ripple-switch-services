require 'doorkeeper/grape/helpers'
require 'grape/kaminari'

module Api
  class Base < Grape::API

    include Concerns::GrapeStrongParams
    include Concerns::GrapeResponder

    #
    # include doorkeeper helpers module
    #
    helpers ::Doorkeeper::Grape::Helpers

    #
    # include kaminari grape helper
    # set default pagination params
    #
    include Grape::Kaminari
    paginate per_page: 20, max_per_page: 30

    prefix 'api'
    format 'json'

    helpers do
      def logger
        Rails.logger
      end
    end

    #
    # catch active record not found exception
    # catch ActiveRecord::NoDatabaseError exception
    #
    rescue_from ::ActiveRecord::RecordNotFound, ActiveRecord::NoDatabaseError do |e|
      error_response(message: "Record not found", status: 404)
    end

    #
    # catch active record invalid exception
    #
    rescue_from ::ActiveRecord::RecordInvalid do |e|
      error_response(message: e.message, status: 422)
    end

    #
    # catch bad request exception
    #
    rescue_from ::ActionController::ParameterMissing, ::ActiveRecord::Rollback do |e|
      error_response(message: e.message, status: 400)
    end

    #
    # catch action controller parameter missing
    #
    rescue_from ::ActionController::ParameterMissing do |e|
      error_response(message: e.message, status: 422)
    end

    #
    # catch Grape::Exceptions::ValidationErrors exception
    # catch Grape::Exceptions::MethodNotAllowed
    #
    rescue_from Grape::Exceptions::ValidationErrors, Grape::Exceptions::MethodNotAllowed do |e|
      error_response(message: e.message, status: 403)
    end

    #
    # rescue from aasm invalid transition
    #
    rescue_from AASM::InvalidTransition do |e|
      error_response(message: e.message, status: 422)
    end

    #
    # rescue from cancan access denied
    #
    #rescue_from ::CanCan::AccessDenied do
    #  error!('403 Forbidden', 403)
    #end

    #
    # rescue from all others exception
    #
    rescue_from :all do |e|
      if !Rails.env.production?
        raise e
      else
        error_response(message: e.backtrace, status: 500)
      end
    end



    helpers do 

      #
      # define filter params
      #
      def filter_params
        params[:filter] || {}
      end

    end

    mount ::Api::V1::Base
    mount ::Api::Webhooks::Base

    route :any do
      error!({ error:  'Not Found',
               detail: "No such route '#{request.path}'",
               status: '404' },
             404)
    end

  end
end