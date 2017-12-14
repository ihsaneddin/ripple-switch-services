class SessionsController < ::Devise::SessionsController

  layout 'landing'

  def create
    generate_login_url
  end

  def generate_login_url
    @token = Users::Models::Account.registration_or_generate_login_by_token account_params
    if @token.nil?
      self.resource = resource_class.new
      respond_to do |f|
        flash[:error]= "Wrong email"
        f.html { render :new }
      end
    else
      Users::Mailers::AccountMailer.delay.login_url(@token.token)
      respond_to do |f|
        f.html{ redirect_to root_path, notice: "Login URL has been sent to your e-mail" }
      end
    end
  end

  def token
    login
  end

  def login
    if token_params.present?
      token = Users::Models::Token.find_and_authenticate token_params[:token]
      if token
        sign_in(:account, token.account)
        respond_to do |f|
          f.html{ redirect_to root_path, notice: "Welcome", status: 301 }
        end
      else
        respond_to do |f|
          f.html{ redirect_to root_path, error: "The link has been expired.", status: 301 }
        end
      end
    end
  end

  def account_params
    params.require(:account).permit(:email)
  end

  def token_params
    params.require(:account).permit(:token)
  end

end
