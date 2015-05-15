class Admin::OrdersController < Admin::BaseController
  def index
    @q = Order.includes(line_items: :order, user: :orders).ransack(search_params)
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
    @q = Order.includes(line_items: :order, user: :orders).ransack(search_params)
    @all_orders = @q.result(distinct: true)
    @orders = @all_orders.page(params[:page])
    render :index
  end

  private

  def search_params
    if params[:q]
      params[:q].each do |k, v|
        params[:q][k] = params[:q][k].strip
        params[:q].delete(k) if params[:q][k].blank?
      end
    else
      params[:q] = {}
    end
  end
end
