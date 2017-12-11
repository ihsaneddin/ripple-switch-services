class PinsController < AccountController

  def update
    if current_account.change_pin 
      message= "New secret PIN has been sent to your e-mail"
      respond_to do |f|
        f.html { redirect_to request.env['HTTP_REFERER'], notice: message }
        f.json { render json: { message: message } }
      end
    else
      respond_to do |f|
        message= "Unable to change secret PIN"
        f.html { redirect_to request.env['HTTP_REFERER'], error: message }
        f.json { render json: { message: message }, status: :unprocessable_entity }
      end
    end
  end

end