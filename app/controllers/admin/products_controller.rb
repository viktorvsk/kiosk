class Admin::ProductsController < Admin::BaseController
  before_action :set_catalog_product, only: [:edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /admin/products
  # GET /admin/products.json
  def index
    @admin_products = Catalog::Product.all
  end

  # GET /admin/products/new
  def new
    @admin_product = Catalog::Product.new
  end

  # GET /admin/products/1/edit
  def edit
  end

  # POST /admin/products
  # POST /admin/products.json
  def create
    @catalog_product = Catalog::Product.new(catalog_product_params)

    respond_to do |format|
      if @catalog_product.save
        format.html { redirect_to @catalog_product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @catalog_product }
      else
        format.html { render :new }
        format.json { render json: @catalog_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/products/1
  # PATCH/PUT /admin/products/1.json
  def update
    respond_to do |format|
      if @catalog_product.update(catalog_product_params)
        format.html { redirect_to @catalog_product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @catalog_product }
      else
        format.html { render :edit }
        format.json { render json: @catalog_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/products/1
  # DELETE /admin/products/1.json
  def destroy
    @catalog_product.destroy
    respond_to do |format|
      format.html { redirect_to catalog_products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_catalog_product
      @catalog_product = Catalog::Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_product_params
      params[:catalog_product]
    end
end
