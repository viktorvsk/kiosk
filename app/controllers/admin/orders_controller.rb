class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: [:edit, :update]
  def index
    @q = Order.includes(:products, line_items: :order, user: :orders).ransack(search_params)
    @all_orders = @q.result(distinct: true).order('completed_at DESC NULLS LAST')
    @orders = @all_orders.page(params[:page])
  end

  def edit
  end

  def update
    if params[:order].try(:[], :line_items_attributes)
      params[:order][:line_items_attributes].each do |li|
        if li.last[:quantity] == '0'
          @order.line_items.find(li.last[:id]).destroy
          params[:order][:line_items_attributes].delete(li.first)
        end
      end
    end
    if @order.update(order_params)
       redirect_to :back
    else
      render :edit
    end
  end

  def create
    @order = Order.new(admin_order_params)
    if @order.save
      redirect_to edit_admin_order_path(@order)
    else
      render :new
    end
  end

  def new
    @order = Order.new
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
    params.require(:order).permit(:name, :phone, :state, :user_id, :address,
      :add_comment, :payment_type, :delivery_type, :admin_order_product,
      line_items_attributes: [:quantity, :price, :vendor_price, :id, :vendor, :serial_numbers])
  end

  def admin_order_params
    params[:order][:creation_way] = 'admin'
    params.require(:order).permit(:name, :phone, :user, :address,
      :payment_type, :delivery_type, :state, :creation_way)
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
