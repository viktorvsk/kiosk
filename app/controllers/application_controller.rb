class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

private
  def authorize_admin!
    redirect_to root_path, notice: 'Только для администраторов' if !current_user.admin?
  end

  def after_sign_in_path_for(resource)
    root_path_by_role = current_user.admin? ? admin_vendor_products_path : user_path
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path_by_role
  end

  def authenticate_admin_user!
    redirect_to new_user_session_path unless current_user.try(:is_admin?)
  end
end
