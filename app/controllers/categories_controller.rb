class CategoriesController < CatalogController
  before_action :set_category, only: [:show]

  # GET /categories
  # GET /categories.json
  def index
    @categories = Category.all
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    q = {
      price_gteq: params[:price_min],
      price_tteq: params[:price_max],
      name_cont: params[:name],
      brand_id_in: params[:b].to_s.split(','),
      filters_cont: params[:f]
    }
    order = params[:o] == 'd' ? 'price DESC' : 'price ASC'
    @all_products = @category.products.includes(:images).ransack(q).result(distinct: true)
    @products = @all_products.order(order).page(params[:page])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Catalog::Category.find(params[:id])
    end

end
