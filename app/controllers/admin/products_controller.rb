class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: [:edit, :show, :update, :destroy, :bind,
                                    :unbind, :recount, :copy_filters,
                                    :copy_properties, :update_product_filter_value,
                                    :update_from_marketplace]
  after_action :set_vendor_product, :recount_product, only: [:bind, :unbind]

  # GET /admin/products
  # GET /admin/products.json
  def index
    @q = Catalog::Product.ransack
    @all_products = Catalog::Product.includes(vendor_products: :product)
    @all_products_count = @all_products.count
    @products = @all_products.page(params[:page])
  end

  def search
    params[:q].each_value do |v| v.strip! end if params[:q]
    @q = Catalog::Product.ransack(params[:q])
    @all_products = @q.result(distinct: true)
    @all_products_count = @all_products.count.respond_to?(:keys) ? @all_products.count.keys.count : @all_products.count
    @products = @all_products.order('created_at DESC').page(params[:page])
    respond_to do |format|
      format.html { render :index }
      format.js
    end
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
        format.html { redirect_to edit_admin_product_path(@product), notice: 'Товар успешно создан.' }
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
      format.js
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

  def update_from_marketplace
    if @product.update_from_marketplace
      @product.save
      redirect_to edit_admin_product_url(@product), notice: 'Характеристики и описание обновлены'
    else
      redirect_to edit_admin_product_url(@product), error: 'Произошла ошибка'
    end
  end

  def copy_filters
    @product.copy_filters_from_category
    redirect_to edit_admin_product_url(@product), notice: 'Фильтры скопированы'
  end

  def copy_properties
    @product.copy_properties_from_category
    redirect_to edit_admin_product_url(@product), notice: 'Характеристики скопированы'
  end

  def update_product_filter_value
    @product.product_filters.find(params[:pfv_id]).update(catalog_filter_value_id: params[:new_id].to_i)
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
      .permit(:name, :model, :catalog_category_id, :fixed_price, :main_name,
              :price, :old_price, :video, :catalog_brand_id, :slug, :description,
              :newest, :homepage, :hit, :images_from_url, :accessories,
              seo_attributes: [:id, :keywords, :description, :title],
              images_from_pc: [],
              product_properties_attributes: [:id, :name, :position, :property_name],
              images_attributes: [:id, :attachment, :position, :_destroy])
  end
end
