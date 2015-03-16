class Admin::Vendor::ProductsController < Admin::BaseController
  before_action :set_admin_vendor_product, only: [:show, :edit, :update, :destroy]

  # GET /admin/vendor/products
  # GET /admin/vendor/products.json
  def index
    @admin_vendor_products = Admin::Vendor::Product.all
  end

  # GET /admin/vendor/products/1
  # GET /admin/vendor/products/1.json
  def show
  end

  # GET /admin/vendor/products/new
  def new
    @admin_vendor_product = Admin::Vendor::Product.new
  end

  # GET /admin/vendor/products/1/edit
  def edit
  end

  # POST /admin/vendor/products
  # POST /admin/vendor/products.json
  def create
    @admin_vendor_product = Admin::Vendor::Product.new(admin_vendor_product_params)

    respond_to do |format|
      if @admin_vendor_product.save
        format.html { redirect_to @admin_vendor_product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @admin_vendor_product }
      else
        format.html { render :new }
        format.json { render json: @admin_vendor_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/vendor/products/1
  # PATCH/PUT /admin/vendor/products/1.json
  def update
    respond_to do |format|
      if @admin_vendor_product.update(admin_vendor_product_params)
        format.html { redirect_to @admin_vendor_product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_vendor_product }
      else
        format.html { render :edit }
        format.json { render json: @admin_vendor_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/vendor/products/1
  # DELETE /admin/vendor/products/1.json
  def destroy
    @admin_vendor_product.destroy
    respond_to do |format|
      format.html { redirect_to admin_vendor_products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_vendor_product
      @admin_vendor_product = Admin::Vendor::Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_vendor_product_params
      params[:admin_vendor_product]
    end
end
