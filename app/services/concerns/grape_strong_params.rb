require 'action_controller/metal/strong_parameters'
module Concerns
module GrapeStrongParams
  extend ActiveSupport::Concern

  included do 
    helpers do

      #
      # change all request params as ActionController::Parameters object
      #
      def posts
        @strong_parameter_object ||= ActionController::Parameters.new(params)
      end

      #
      # define filter params
      #
      def filter_params
        params[:filter] || {}
      end

      #
      # define pagination params
      #
      def pagination_params
        { per_page: params[:per_page] || 10, page: params[:page] }
      end

    end
  end
end
end