class Admin::Vendor::ProductsController < Admin::BaseController
  # GET /admin/vendor/products
  # GET /admin/vendor/products.json
  def index
    @q_vendor_products = ::Vendor::Product.ransack(params[:q_vendor_products])
    @q_catalog_products = ::Catalog::Product.ransack(params[:q_catalog_products])
  end

  def search
    @q_vendor_products = ::Vendor::Product.unbound.ransack(params[:q])
    @products = @q_vendor_products.result.page(params[:page])
  end

end
