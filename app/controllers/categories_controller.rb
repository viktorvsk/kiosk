class CategoriesController < CatalogController
  before_action :set_category, only: [:show, :compare, :add_to_compare]

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
    @brand = Catalog::Brand.where(id: params[:b]).first
    @filters_and_results_hash = {
      filters: @category.category_filters.includes(filter: :values),
      brands: @category.brands.uniq,
      products: @products,
      products_count: @all_products.count,
      all_products: @all_products
    }
  end

  def compare
    @products =  Catalog::Product.includes(:category, product_properties: :property).where(id: session[:comparing_ids].to_s.split, category: @category)
  end

  def add_to_compare
    @product = Catalog::Product.find(params[:product_id])
    comparing = @comparing_products
    comparing << @product.id.to_s
    session[:comparing_ids] = comparing.uniq.join(' ')
    set_comparing_products
    render 'categories/update_compare_button'
  end

  def remove_from_compare
    @product = Catalog::Product.find(params[:product_id])
    comparing = @comparing_products
    comparing = comparing - [@product.id.to_s]
    session[:comparing_ids] = comparing.uniq.join(' ')
    set_comparing_products
    respond_to do |format|
      format.js { render 'categories/update_compare_button' }
      format.html { redirect_to :back }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Catalog::Category.find(params[:id])
    end

end
