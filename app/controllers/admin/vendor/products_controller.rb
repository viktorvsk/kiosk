class Admin::Vendor::ProductsController < Admin::BaseController
  # GET /admin/vendor/products
  # GET /admin/vendor/products.json
  def index
    @q_vendor_products = ::Vendor::Product.ransack(params[:q_vendor_products])
    @q_catalog_products = ::Catalog::Product.ransack(params[:q_catalog_products])
  end

  def show
    @product = ::Vendor::Product.find(params[:id])
    respond_to :js
  end

  def search
    @q_vendor_products = ::Vendor::Product.unbound.ransack(params[:q])
    @products = @q_vendor_products.result.order('updated_at DESC').page(params[:page])
  end

  def toggle_activation
    @vendor_product = ::Vendor::Product.find(params[:id])
    @vendor_product.active? ? @vendor_product.deactivate : @vendor_product.activate
    @vendor_product.product.recount if @vendor_product.product
    # render text: @product.state.try(:name)
  end

end
