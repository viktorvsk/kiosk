class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  layout 'admin'

  def dashboard
    render 'admin/dashboard'
    authorize! :manage, :content
  end

  private

  def check_content_manager_permissions
    authorize! :manage, :content
  end

  def check_admin_permissions
    authorize! :manage, :everything
  end

end
