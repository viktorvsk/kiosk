class OrdersController < CatalogController

  def update
    @current_order.update(order_params)
    respond_to do |format|
      format.js do
        @render_hash = {
          partial: 'orders/form',
          layout: false,
          locals: {
            order: @current_order,
            instant: false,
            product_id: nil
          }
        }
      end
    end
  end

  def show
  end

  def checkout
    if params[:order].try(:[], :super_instant) == 'true'
      @current_order.line_items.destroy_all
      phone = Catalog.strip_phone(params[:order][:phone])
      @current_order.add_product(params[:order][:product_id])
      @current_order.update!(creation_way: 'instant_checkout', name: 'Купил в 1 клик', phone: phone)
    end
    head 422 and return unless @current_order.ready?
    if params[:instant] == 'true'
      @current_order.line_items.destroy_all
      @current_order.add_product(params[:product_id])
      @current_order.update(creation_way: 'instant_checkout')
    end
    pass = Devise.friendly_token
    user = User.where(phone: @current_order.phone).first_or_create!(email: "#{@current_order.phone}@kiosk.evotex.kh.ua", password: pass, password_confirmation: pass)
    if @current_order.creation_way == 'instant_checkout'
      creation_way = 'instant_checkout'
    elsif current_user.try(:admin?)
      creation_way = 'admin'
    else
      creation_way = 'default'
    end
    @current_order.line_items.map(&:fix_price!)
    @current_order.update!(state: 'checkout', user: user, completed_at: Time.now, creation_way: creation_way)
    session[:order_id] = nil
    if session[:ordered].present?
      session[:ordered] = session[:ordered].to_s << " #{@current_order.id}"
    else
      session[:ordered] = @current_order.id.to_s
    end
    @bla = '10'
    redirect_to user_path, notice: "Заказ успешно оформлен. Номер заказа: #{@current_order.id}"
  end

  def update_lineitem_count
    params[:line_items].each do |id, values|
      q = values[:quantity]
      li = @current_order.line_items.find(id)
      if q.to_i < 1
        li.destroy
      else
        li.update(quantity: q)
      end
    end
    respond_to do |format|
      format.js { head 200 }
      format.html { redirect_to order_path }
    end
  end

  def remove_product
    @current_order.line_items.where(catalog_product_id: params[:product_id]).first.destroy
    redirect_to order_path
  end

  def add_product
    if @current_order.add_product(params[:product_id])
      redirect_to order_path
    else
      head 422
    end
  end

  private

  def order_params
    if params[:order][:phone].blank?
      params[:order][:phone] = nil
      params[:order].permit(:name, :address, :phone, :comment, :delivery_type, :payment_type)
    else
      params[:order].permit(:name, :phone, :address, :comment, :delivery_type, :payment_type)
    end

  end

end
