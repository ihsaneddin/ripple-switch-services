module Users
  module Serializers
    class AccountSerializer < ::ActiveModel::Serializer
    
      attributes :username, :email, :deleted_at, :created_at, :updated_at

    end
  end
end