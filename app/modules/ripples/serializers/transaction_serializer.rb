module Ripples
  module Serializers
    class TransactionSerializer < ::ActiveModel::Serializer
    
      attributes :id, :tx_hash, :source_address, :source_currency, :destination_address, :destination_currency, :amount, :transaction_type, :state, :validated, :created_at, :updated_at

      def source_address
        object.source || object.source_wallet.address
      end

      def destination_address
        object.destination
      end

    end
  end
end