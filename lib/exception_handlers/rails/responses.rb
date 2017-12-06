#
# this module is collection of modules that handle exception on controller stack
#

module ExceptionHandlers
  module Rails
    module Responses
      extend ::ActiveSupport::Concern
      extend ::ActiveSupport::Rescuable::ClassMethods

      included do 

        #
        # handle ActiveRecord::NoDatabaseError
        # TODO : change the text message using internasionalization
        #
        rescue_from ::ActiveRecord::NoDatabaseError do |e|
          render json:  {
                          message: "Not found",
                          status: 404
                        }
        end
      end
    end  
  end
end