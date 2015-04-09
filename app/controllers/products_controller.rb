class ProductsController < CatalogController
  before_action :set_product, only: [:show]

  # GET /products
  # GET /products.json
  def index
    @q = Catalog::Product.ransack
    @products = Catalog::Product.page(params[:page])
  end

  def search
    params[:q].each_value do |v| v.strip! end if params[:q]
    @q = Catalog::Product.ransack(params[:q])
    @products = @q.result.order('created_at DESC').page(params[:page])
    render :index
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
