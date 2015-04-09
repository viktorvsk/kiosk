class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: [:edit, :show, :update, :destroy, :bind, :unbind, :recount]
  after_action :set_vendor_product, :recount_product, only: [:bind, :unbind]

  # GET /admin/products
  # GET /admin/products.json
  def index
    @q = Catalog::Product.ransack
    @products = Catalog::Product.includes(vendor_products: :product).page(params[:page])
  end

  def search
    params[:q].each_value do |v| v.strip! end if params[:q]
    @q = Catalog::Product.ransack(params[:q])
    @products = @q.result.order('created_at DESC').page(params[:page])
    render :index
  end

  def show
    render @product.reload, layout: false
  end

  # GET /admin/products/new
  def new
    @product = Catalog::Product.new
    @product.build_seo
  end

  # GET /admin/products/1/edit
  def edit
    @product.build_seo unless @product.seo
  end

  # POST /admin/products
  # POST /admin/products.json
  def create
    @product = Catalog::Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to admin_products_path(@product), notice: 'Товар успешно создан.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/products/1
  # PATCH/PUT /admin/products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to edit_admin_product_url(@product), notice: 'Товар успешно обновлен.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/products/1
  # DELETE /admin/products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to admin_products_url, notice: 'Товар успешно удален.' }
      format.json { head :no_content }
    end
  end

  def bind
    @product.bind(@vendor_product)
    head 200
  end

  def unbind
    @product.unbind(@vendor_product)
    head 200
  end

  def recount
    @product.recount
    head 200
  end

  def search_marketplaces
    @marketplaces = Catalog::Product.search_marketplaces_by_model(params[:model])
  end

  def create_from_marketplace
    category = Catalog::Category.find(params[:category_id])
    url = URI.decode params[:url]
    model = URI.decode params[:model]
    product = Catalog::Product.create_from_marketplace(url, category: category, model: model)
    vendor_product = Vendor::Product.ransack(model_cont: model).result.bind_to(product)
    head 200
  end

  private

  def set_product
    @product = ::Catalog::Product
               .where(id: params[:id])
               .includes(product_properties: :property).first
  end

  def set_vendor_product
    @vendor_product = ::Vendor::Product.find(params[:vendor_product_id])
  end

  def recount_product
    @product.recount
  end

  def product_params
    params.require(:catalog_product)
      .permit(:name, :model, :category, :fixed_price, :main_name,
              :price, :old_price, :video, :brand, :slug, :description,
              :newest, :homepage, :hit,
              seo_attributes: [:id, :keywords, :description, :title],
              product_properties_attributes: [:id, :name, :position, :property_name])
  end
end
