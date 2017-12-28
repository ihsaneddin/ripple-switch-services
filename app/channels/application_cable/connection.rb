module ApplicationCable
  class Connection < ActionCable::Connection::Base

    identified_by :current_account

    def connect
      self.current_account = find_verified_account
    end

    protected
      def find_verified_account
        if current_account= env['warden'].user
          current_account
        else
          reject_unauthorized_connection
        end
      end

  end
end
