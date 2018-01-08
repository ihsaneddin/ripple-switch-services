module Ripple
  class ExportSecretsController < AccountController

    include Supports::EncryptedRequests::Helpers::EncryptRequest::Controller

  end
end