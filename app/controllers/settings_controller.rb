class SettingsController < AccountController

  helper_method :setting

  def index
    
  end

  def update
    if current_account.update setting_params
      message = "Your setting has been updated."
      respond_to do |f|
        f.html{ 
          if !current_account.confirmed?
            flash[:alert]= "You must confirm your new email to prevent locked out of your account."
          else 
            flash[:notice]= message
          end
          render :index 
        }
        f.js {
          params[:notification]= { message: message }
          render_notification
        }
      end
    else
      message = "An error has prevented setting to be saved."
      respond_to do |f|
        f.html{ 
          flash[:error]= message
          render :index
         }
        f.js{
          params[:notification]= { message: message, type: "error" }
        }
      end
    end
  end

  protected 

    def setting
      @setting||= current_account.cached_setting || Supports::Settingable::Models::Setting.new 
    end

    def setting_params
      params.require(:users_models_account).permit(:email, :setting_ipn_key, :setting_ipn_url, :setting_ipn_state, :save_changed_setting)
    end

end