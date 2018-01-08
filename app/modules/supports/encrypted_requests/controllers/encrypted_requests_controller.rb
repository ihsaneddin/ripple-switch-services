module Supports
  module EncryptedRequests
    module Controllers
      class EncryptedRequestsController < ApplicationController

        include Supports::EncryptedRequests::Helpers::EncryptRequest::Controller

      end
    end
  end
end