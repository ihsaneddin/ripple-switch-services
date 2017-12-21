module Users
  module Helpers
    module SubscriptionRestriction
    
      extend ActiveSupport::Concern

      module Controller
        
        include ActiveSupport::Concern

        def restrict_address_creation options={}
          current_plan = current_account.active_plan || Users::Models::Plan.free.first
          if current_plan.present? && (current_account.wallets.cached_with_deleted_collection.count < (current_plan.max_wallets_count || 10))
            block_given? ? yield : true 
          else
            respond_to do |f|
              f.html{ redirect_to request.env['HTTP_REFERER'], error: "Maximum address created has reached!" }
              f.js{
                params[:notification]= { message: "Maximum address created has reached", type: "error" }
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

        included do 
          helpers HelperMethods
        end

        module HelperMethods

          def restrict_address_creation options={}
            current_plan = current_account.active_plan || Users::Models::Plan.free.first
            if current_plan.present? && (current_account.wallets.cached_with_deleted_collection.count < (current_plan.max_wallets_count || 10))
              block_given? ? yield : true 
            else
              error!('Maximum address created has reached', 401)
            end
          end

        end

      end

    end
  end
end