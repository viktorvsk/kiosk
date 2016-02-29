class Admin::BrandsController < Admin::BaseController
  before_action :check_content_manager_permissions
  before_action :set_brand, only: [:edit, :update, :destroy]

  def index
    @q = Catalog::Brand.ransack
    @brands = Catalog::Brand.order(created_at: :desc).page(params[:page])
  end

  def search
    params[:q].each_value do |v| v.strip! end if params[:q]
    @q = Catalog::Brand.ransack(params[:q])
    @brands = @q.result.order('created_at DESC').page(params[:page])
    render :index
  end

  def new
    @brand = ::Catalog::Brand.new
    @brand.build_seo
    @brand.build_image
  end

  def edit
    @brand.build_seo unless @brand.seo
    @brand.build_image unless @brand.image
  end

  def create
    @brand = ::Catalog::Brand.new(brand_params)
    if @brand.save
       redirect_to admin_brands_url
    else
      render :new
    end
  end

  def update
    if @brand.update(brand_params)
      redirect_to admin_brands_url
    else
      render :edit
    end
  end

  def destroy
    @brand.destroy
    redirect_to admin_brands_url
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
