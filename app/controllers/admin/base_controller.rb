class Admin::BaseController < ApplicationController
  before_action :authenticate_user!, :authorize_admin!
  layout 'admin'

  def dashboard
    render 'admin/dashboard'
  end
end
