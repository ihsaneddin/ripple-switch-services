require 'base64'
require 'openssl'

module Api
  module Webhooks
    class TestIPN < Base
    
      resources "test" do 

        post do 
          debugger
          p "#{request.body.read}"
          p headers
          message message: "Ok"
            
        end

      end

    end
  end
end