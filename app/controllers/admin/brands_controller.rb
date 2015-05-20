class Admin::BrandsController < Admin::BaseController
  before_action :check_content_manager_permissions
  before_action :set_brand, only: [:edit, :update, :destroy]

  # GET /admin/brands
  def index
    @q = Catalog::Brand.ransack
    @brands = Catalog::Brand.page(params[:page])
  end

  def search
    params[:q].each_value do |v| v.strip! end if params[:q]
    @q = Catalog::Brand.ransack(params[:q])
    @brands = @q.result.order('created_at DESC').page(params[:page])
    render :index
  end

  # GET /admin/brands/new
  def new
    @brand = ::Catalog::Brand.new
    @brand.build_seo
    @brand.build_image
  end

  # GET /admin/brands/1/edit
  def edit
    @brand.build_seo unless @brand.seo
    @brand.build_image unless @brand.image
  end

  # POST /admin/brands
  def create
    @brand = ::Catalog::Brand.new(brand_params)

    respond_to do |format|
      if @brand.save
        format.html { redirect_to admin_brands_url, notice: 'Бренд создан.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /admin/brands/1
  def update
    respond_to do |format|
      if @brand.update(brand_params)
        format.html { redirect_to admin_brands_url, notice: 'Бренд обновлен.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /admin/brands/1
  def destroy
    @brand.destroy
    respond_to do |format|
      format.html { redirect_to admin_brands_url, notice: 'Бренд удален.' }
      format.json { head :no_content }
    end
  end

  private

  def set_brand
    @brand = Catalog::Brand.find(params[:id])
  end

  def brand_params
    params.require(:catalog_brand).permit(:name, :description, :slug,
                                          seo_attributes: [:title, :keywords, :description],
                                          image_attributes: [:attachment])
  end
end
