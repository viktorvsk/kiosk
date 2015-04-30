class OrdersController < CatalogController
  def update
    params[:line_items].each do |id, values|
      @current_order.line_items.find(id).update(quantity: values[:quantity])
    end
    respond_to do |format|
      format.js { head 200 }
      format.html { redirect_to order_path }
    end
  end

  def show
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
end
