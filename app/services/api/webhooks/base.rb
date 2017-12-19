module Api
  module Webhooks
    class Base < ::Api::Base

      version "webhooks", using: :path

      mount Coinspayment

    end
  end
end