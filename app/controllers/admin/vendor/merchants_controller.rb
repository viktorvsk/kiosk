class Admin::Vendor::MerchantsController < Admin::BaseController
  before_action :set_merchant, only: [:show, :edit, :update, :destroy]

  # GET /admin/vendor/merchants
  # GET /admin/vendor/merchants.json
  def index
    @merchants = ::Vendor::Merchant.all
  end

  # GET /admin/vendor/merchants/1
  # GET /admin/vendor/merchants/1.json
  def show
  end

  # GET /admin/vendor/merchants/new
  def new
    @merchant = ::Vendor::Merchant.new
  end

  # GET /admin/vendor/merchants/1/edit
  def edit
  end

  # POST /admin/vendor/merchants
  # POST /admin/vendor/merchants.json
  def create
    @merchant = ::Vendor::Merchant.new(merchant_params)

    respond_to do |format|
      if @merchant.save
        format.html { redirect_to admin_vendor_merchants_path, notice: 'Merchant was successfully created.' }
        format.json { render :show, status: :created, location: @merchant }
      else
        format.html { render :new }
        format.json { render json: @merchant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/vendor/merchants/1
  # PATCH/PUT /admin/vendor/merchants/1.json
  def update
    respond_to do |format|
      if @merchant.update(merchant_params)
        format.html { redirect_to admin_vendor_merchants_path, notice: 'Merchant was successfully updated.' }
        format.json { render :show, status: :ok, location: @merchant }
      else
        format.html { render :edit }
        format.json { render json: @merchant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/vendor/merchants/1
  # DELETE /admin/vendor/merchants/1.json
  def destroy
    @merchant.destroy
    respond_to do |format|
      format.html { redirect_to admin_vendor_merchants_url, notice: 'Merchant was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_merchant
      @merchant = ::Vendor::Merchant.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def merchant_params
      params.require(:vendor_merchant).permit(:name)
    end
end
