module Admin
  class SessionsController < ::Devise::SessionsController
    
    layout 'session'

    private

    def after_sign_in_path_for(resource)
      admin_path
    end

    # Overwriting the sign_out redirect path method
    def after_sign_out_path_for(resource_or_scope)
      new_admin_session_path
    end

  end
end