class Admin::CategoriesController < Admin::BaseController
  before_action :check_admin_permissions
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
        format.html { redirect_to edit_admin_category_url(@category), notice: 'Категория создана.' }
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
        format.html { redirect_to edit_admin_category_url(@category), notice: 'Категория обновлена.' }
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

  def reorder_all_properties
    @category = Catalog::Category.find(params[:category_id])
    @category.reorder_all_properties
    head 200
  end

  def add_filter
    @category = Catalog::Category.find(params[:category_id])
    filter = @category.add_filter(params[:catalog_filter][:name], @category.name)
    render :refilter
  end

  def add_filter_value
    @category = Catalog::Category.find(params[:category_id])
    filter = Catalog::Filter.find(params[:catalog_filter_value][:filter_id])
    filter.add_value(params[:catalog_filter_value][:name], filter.name)
    render :refilter
  end

  def remove_filter
    @category = Catalog::Category.find(params[:category_id])
    category_filter = @category.category_filters.where(id: params[:filter_id].to_i).first
    @filter_id = category_filter.id.to_s
    category_filter.filter.destroy
  end

  def remove_filter_value
    @category = Catalog::Category.find(params[:category_id])
    filter_value = Catalog::FilterValue.where(id: params[:filter_value_id]).first
    if filter_value
      @filter_value_id = filter_value.id.to_s
      filter_value.destroy
    else
      head 200
    end
  end

  def reorder_filters
    category = Catalog::Category.find(params[:category_id])
    category.update(reorder_filter_values: params[:reorder_filter_values], reorder_filters: params[:reorder_filters])
    head 200
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = ::Catalog::Category.includes(:properties, :filters => [:values]).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:catalog_category).permit(:name, :tax, :tax_threshold, :active,
        :tax_max, :catalog_taxon_id, :description, :s_name, :slug, :all_aliases,
        seo_attributes: [:id, :title, :description, :keywords])
    end

end
