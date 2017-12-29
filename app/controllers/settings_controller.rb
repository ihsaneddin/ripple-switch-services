class SettingsController < AccountController

  helper_method :setting

  def index
    
  end

  def update
    
  end

  protected 

    def setting
      @setting||= current_account.cached_setting || Supports::Settingable::Models::Setting.new 
    end

    def setting_params
      
    end

end