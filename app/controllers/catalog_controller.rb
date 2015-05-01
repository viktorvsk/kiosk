class CatalogController < ApplicationController
  before_action :set_current_order

  private

  def set_current_order
    current_user ? set_order_for_user : set_order_for_guest
  end

  def set_order_for_user
    @current_order = Order.in_cart.where(id: session[:order_id], user: nil).first ||
      current_user.current_order || current_user.create_current_order(phone: current_user.phone, name: current_user.name)
    session[:order_id] = @current_order.id
    if !@current_order.user
      current_user.current_order.destroy
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
