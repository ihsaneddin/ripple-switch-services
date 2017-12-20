module Admin
  class AdminController < ApplicationController
  
    before_action :authenticate_admin!

    layout 'admin'

    include ModalViewHelper::Concern, Resources, TableViewHelper::Concern

    helper_method :filter_params

    def filter_params
      params[:filter] || {}
    end

  end
end