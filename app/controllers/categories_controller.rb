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
    @products = @category.products.includes(:images).page(params[:page])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Catalog::Category.find(params[:id])
    end

end
