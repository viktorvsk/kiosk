class Admin::BindingController < Admin::BaseController
  before_action :check_content_manager_permissions

  def bind
    @product = ::Catalog::Product.find(params[:product_id])
    @vendor_product = ::Vendor::Product.find(params[:vendor_product_id])
    if ( @product && @vendor_product )
      @product.bind(@vendor_product)
      @product.reload.recount
      head 200
      current_user.record!(@product, 'Привязал', @vendor_product.name)
    else
      head 502
    end


  end

  def unbind
    @vendor_product = ::Vendor::Product.find(params[:vendor_product_id])
    @product =  @vendor_product.product
    if ( @product && @vendor_product )
      current_user.record!(@product, 'Отвязал', @vendor_product.name)
      @vendor_product.unbind
      @product.reload.recount
      head 200
    else
      head 502
    end
  end
end
