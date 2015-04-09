class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: [:show, :edit, :update, :destroy, :remove_property]

  # GET /admin/categories
  # GET /admin/categories.json
  def index
    @q = Catalog::Category.ransack
    @categories = Catalog::Category.page(params[:page])
  end

  def search
    params[:q].each_value do |v| v.strip! end if params[:q]
    @q = Catalog::Category.ransack(params[:q])
    @categories = @q.result.order('created_at DESC').page(params[:page])
    render :index
  end

  # GET /admin/categories/new
  def new
    @category = ::Catalog::Category.new
  end

  # GET /admin/categories/1/edit
  def edit
  end

  # POST /admin/categories
  # POST /admin/categories.json
  def create
    @category = ::Catalog::Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to admin_categories_url, notice: 'Категория создана.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /admin/categories/1
  # PATCH/PUT /admin/categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to admin_categories_url, notice: 'Категория обновлена.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /admin/categories/1
  # DELETE /admin/categories/1.json
  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to admin_categories_url, notice: 'Категория удалена.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = ::Catalog::Category.includes(:properties).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:catalog_category).permit(:name, :tax, :tax_threshold, :tax_max)
    end
end
