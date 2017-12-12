module Api
  module V1
    module Presenters
      class Wallet < ::Grape::Entity

        expose :id
        expose :label
        expose :address
        expose :xrp_balance do |wallet, options| 
          begin
            wallet.get_xrp_balance
          rescue Ripple::MalformedTransaction
            0       
          end
        end
        expose :deleted_at
        expose :created_at
        expose :updated_at

      end
    end
  end
end