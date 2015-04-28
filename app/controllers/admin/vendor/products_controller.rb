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

  def update
    @product = ::Vendor::Product.find(params[:id])
    @product.update(product_params)
    head 200
  end

  def search
    params[:q].each_value do |v| v.strip! end
    @q_vendor_products = ::Vendor::Product.unbound.ransack(params[:q])
    @products = @q_vendor_products.result.order('updated_at DESC').page(params[:page])
  end

  def toggle_activation
    @vendor_product = ::Vendor::Product.find(params[:id])
    @vendor_product.toggle!(:trashed)
    @vendor_product.product.recount if @vendor_product.product
  end

  private

  def product_params
    params.require(:vendor_product).permit(:model)
  end

end
