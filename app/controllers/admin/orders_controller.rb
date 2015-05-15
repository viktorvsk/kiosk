class Admin::OrdersController < Admin::BaseController
  def index
    params[:q].each_value do |v| v.strip! end if params[:q]
    @q = Order.includes(line_items: :order, user: :orders).ransack(params[:q])
    @all_orders = @q.result(distinct: true)
    @orders = @all_orders.page(params[:page])
  end

  def edit
  end

  def update
  end

  def create
  end

  def new
  end

  def search
    params[:q].each_value do |v| v.strip! end if params[:q]
    @q = Order.includes(line_items: :order, user: :orders).ransack(params[:q])
    @all_orders = @q.result(distinct: true)
    @orders = @all_orders.page(params[:page])
    render :index
  end
end
