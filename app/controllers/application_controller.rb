class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_current_order

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

  def set_current_order
    return if request.path =~ /^\/admin/
    current_user ? set_order_for_user : set_order_for_guest
  end

  def set_order_for_user
    @current_order = Order.in_cart.where(id: session[:order_id], user: nil).first ||
      current_user.current_order || current_user.create_current_order(phone: current_user.phone, name: current_user.name)
    session[:order_id] = @current_order.id
    if !@current_order.user
      current_user.current_order.try(:destroy)
      @current_order.update user: current_user, name: current_user.name, phone: current_user.phone
    end
  end

  def set_order_for_guest
    if session[:order_id]
      @current_order = Order.in_cart.where(id: session[:order_id]).first || Order.create
    else
      @current_order = Order.create!
      session[:order_id] = @current_order.id
    end
  end
end
