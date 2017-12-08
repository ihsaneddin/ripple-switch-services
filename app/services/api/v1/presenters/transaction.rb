module Api
  module V1
    module Presenters
      class Transaction < ::Grape::Entity

        expose :id
        expose :address do |t|
          t.wallet.address
        end
        expose :destination
        expose :amount
        expose :tx_hash
        expose :currency
        expose :deleted_at
        expose :created_at
        expose :updated_at

      end
    end
  end
end