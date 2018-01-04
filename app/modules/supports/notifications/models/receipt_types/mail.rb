#
# this class is used to push notification to recipient object
# recipient class must implement IPN::Helpers::HasNotifications module and override #ipn_key and #ipn_url methods
#

module Supports
  module Notifications
    module Models
      module ReceiptTypes
        class Mail < Supports::Notifications::Models::Receipt

          has_options fields: { ipn_key: nil, ipn_url: nil },
                      validations: { 
                                      email: { presence: true }
                                    } 

        end
      end
    end
  end
end