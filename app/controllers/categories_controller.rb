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
    if params[:slug] != @category.slug
      redirect_to c_path(slug: @category.slug, id: @category), status: 301
    end
    order = params[:o] == 'd' ? 'price DESC NULLS LAST' : 'price ASC NULLS LAST'
    @all_products = @category.products.by_category_params(params)
    @products = @all_products.zeros_last.order(order).page(params[:page])
    @filters_and_results_hash = {
      filters: @category.category_filters.includes(filter: :values),
      brands: @category.brands.uniq,
      products: @products,
      products_count: @all_products.count,
      all_products: @all_products
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Catalog::Category.find(params[:id])
    end

end
