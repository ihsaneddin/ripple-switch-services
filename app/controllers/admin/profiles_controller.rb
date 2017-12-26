module Admin 
  class ProfilesController < AdminController
    
    def edit
      respond_to do |f|
        f.html
        f.js do 
          render_modal if modal_params_present?
        end
      end
    end

    def update
      if profile.update profile_params
        bypass_sign_in(profile)
        message = "Password is updated."
        respond_to do |f|
          f.html { redirect_to admin_path, notice: message }
          f.js do 
            params[:notification]= { message: message }
            dismiss_modal
          end
        end
      else
        message = "An error has ocurred."
        respond_to do |f|
          f.html { render :edit }
          f.js {
            params[:notification]= { message: message, type: "error" }
            render_modal
          }
        end
      end
    end

    def profile_params
      params.require(:administration_models_admin).permit(:password, :password_confirmation)
    end

    def profile
      @profile||= current_admin
    end

  end
end