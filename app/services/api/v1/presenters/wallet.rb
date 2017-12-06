module Api
  module V1
    module Presenters
      class Wallet < ::Grape::Entity

        expose :id
        expose :label
        expose :address
        expose :deleted_at
        expose :created_at
        expose :updated_at

      end
    end
  end
end