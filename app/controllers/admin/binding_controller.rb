class Admin::BindingController < Admin::BaseController
  def bind
    @product = ::Catalog::Product.find(params[:product_id])
    @vendor_product = ::Vendor::Product.find(params[:vendor_product_id])
    @product.bind(@vendor_product)
    @product.recount
    head 200
  end

  def unbind
    @vendor_product = ::Vendor::Product.find(params[:vendor_product_id])
    @product =  @vendor_product.product
    @vendor_product.unbind
    @product.recount
    head 200
  end
end
