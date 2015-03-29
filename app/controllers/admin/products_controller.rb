class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: [:edit, :show, :update, :destroy, :bind, :unbind, :recount]
  after_action :set_vendor_product, :recount_product, only: [:bind, :unbind]

  # GET /admin/products
  # GET /admin/products.json
  def index
    @products = Catalog::Product.page(params[:page])
  end

  def show
    render @product.reload, layout: false
  end

  # GET /admin/products/new
  def new
    @product = Catalog::Product.new
  end

  # GET /admin/products/1/edit
  def edit
  end

  # POST /admin/products
  # POST /admin/products.json
  def create
    @product = Catalog::Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
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
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
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
      format.html { redirect_to admin_products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    @q = ::Catalog::Product.ransack(params[:q])
    @products = @q.result.order('updated_at DESC').page(params[:page])
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = ::Catalog::Product.find(params[:id])
    end

    def set_vendor_product
      @vendor_product = ::Vendor::Product.find(params[:vendor_product_id])
    end

    def recount_product
      @product.recount
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params[:product]
    end
end
