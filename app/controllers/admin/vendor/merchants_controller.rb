class Admin::Vendor::MerchantsController < Admin::BaseController
  before_action :set_admin_vendor_merchant, only: [:show, :edit, :update, :destroy]

  # GET /admin/vendor/merchants
  # GET /admin/vendor/merchants.json
  def index
    @admin_vendor_merchants = Admin::Vendor::Merchant.all
  end

  # GET /admin/vendor/merchants/1
  # GET /admin/vendor/merchants/1.json
  def show
  end

  # GET /admin/vendor/merchants/new
  def new
    @admin_vendor_merchant = Admin::Vendor::Merchant.new
  end

  # GET /admin/vendor/merchants/1/edit
  def edit
  end

  # POST /admin/vendor/merchants
  # POST /admin/vendor/merchants.json
  def create
    @admin_vendor_merchant = Admin::Vendor::Merchant.new(admin_vendor_merchant_params)

    respond_to do |format|
      if @admin_vendor_merchant.save
        format.html { redirect_to @admin_vendor_merchant, notice: 'Merchant was successfully created.' }
        format.json { render :show, status: :created, location: @admin_vendor_merchant }
      else
        format.html { render :new }
        format.json { render json: @admin_vendor_merchant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/vendor/merchants/1
  # PATCH/PUT /admin/vendor/merchants/1.json
  def update
    respond_to do |format|
      if @admin_vendor_merchant.update(admin_vendor_merchant_params)
        format.html { redirect_to @admin_vendor_merchant, notice: 'Merchant was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_vendor_merchant }
      else
        format.html { render :edit }
        format.json { render json: @admin_vendor_merchant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/vendor/merchants/1
  # DELETE /admin/vendor/merchants/1.json
  def destroy
    @admin_vendor_merchant.destroy
    respond_to do |format|
      format.html { redirect_to admin_vendor_merchants_url, notice: 'Merchant was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_vendor_merchant
      @admin_vendor_merchant = Admin::Vendor::Merchant.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_vendor_merchant_params
      params[:admin_vendor_merchant]
    end
end
