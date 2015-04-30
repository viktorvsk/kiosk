class CatalogController < ApplicationController
  before_action :set_current_order

  private

  def set_current_order
    if !current_user
      if session[:order_id]
        @current_order = Order.where(id: session[:order_id]).first || Order.create
      else
        @current_order = Order.create!
        session[:order_id] = @current_order.id
      end
    else
      @current_order = current_user.current_order || current_user.create_current_order
    end
  end
end
