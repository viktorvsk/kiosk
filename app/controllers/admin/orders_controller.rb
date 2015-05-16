class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: [:edit, :update]
  def index
    @q = Order.includes(line_items: :order, user: :orders).ransack(search_params)
    @all_orders = @q.result(distinct: true)
    @orders = @all_orders.page(params[:page])
  end

  def edit
  end

  def update
    if @order.update(order_params)
      redirect_to :back
    else
      render :edit
    end
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

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    c = params[:order][:add_comment]
    if c.present?
      named_comment = %(<hr/><b>#{current_user.name}</b>: #{c} <div class='text-right'> #{Time.now.strftime("%x %X")}</div>)
      params[:order][:add_comment] = named_comment
    end
    params.require(:order).permit(:name, :phone, :state, :user, :address,
                                  :add_comment, :payment_type, :delivery_type)
  end

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
