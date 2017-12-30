class PlansController < AccountController

  before_action :subscribing?

  def index
    @plans = Users::Models::Plan.cached_collection.active
    @current_plan = current_account.active_plan
    respond_to do |f|
      f.html
      f.js
      f.json
    end
  end

end