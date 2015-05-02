class ProductsController < CatalogController
  before_action :set_product, only: [:show]

  # GET /products
  # GET /products.json
  def index
    @newest = Catalog::Product.with_price.top(:newest).uniq
    @homepage = Catalog::Product.with_price.top(:homepage).uniq
    @hit = Catalog::Product.with_price.top(:hit).uniq
  end

  def search
    params[:q].each_value { |v| v.strip! } if params[:q]
    @q = Catalog::Product.includes(:images).ransack(params[:q])
    @all_products = @q.result
    @products = @all_products.zeros_last.order('price ASC').page(params[:page])
    # TODO: hack the fuck
    @grouped_hash = @all_products.select('catalog_products.id').group('catalog_category_id').count
    @grouped_hash = @grouped_hash.map do |k,v|
      [Catalog::Category.select(:id, :name, :slug).find(k), v]
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
