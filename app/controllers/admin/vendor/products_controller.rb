class Admin::Vendor::ProductsController < Admin::BaseController
  # GET /admin/vendor/products
  # GET /admin/vendor/products.json
  def index
    @products = ::Vendor::Product.limit(100)
  end

end
