class ProductsController < CatalogController
  before_action :set_product, only: [:show]

  # GET /products
  # GET /products.json
  def index
    @products = Catalog::Product.all
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Catalog::Product.find(params[:id])
    end

end
