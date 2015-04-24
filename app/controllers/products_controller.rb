class ProductsController < CatalogController
  before_action :set_product, only: [:show]

  # GET /products
  # GET /products.json
  def index
    @newest = Catalog::Product.top(:newest)
    @homepage = Catalog::Product.top(:homepage)
    @hit = Catalog::Product.top(:hit)
  end

  def search
    params[:q].each_value { |v| v.strip! } if params[:q]
    @q = Catalog::Product.ransack(params[:q])
    @all_products = @q.result.order('price ASC')
    @products = @all_products.page(params[:page])
    # TODO: hack the fuck
    @grouped_hash = @all_products.select('catalog_products.*').group('price, catalog_category_id').count
    @grouped_hash = @grouped_hash.map do |k,v|
      [Catalog::Category.select(:id, :name).find(k), v]
    end
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
