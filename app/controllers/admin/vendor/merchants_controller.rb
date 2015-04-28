class Admin::Vendor::MerchantsController < Admin::BaseController
  before_action :set_merchant, only: [:show, :edit, :update, :destroy, :pricelist]
  before_action :set_custom_merchants, only: [:new, :edit]

  # GET /admin/vendor/merchants
  # GET /admin/vendor/merchants.json
  def index
    @merchants = ::Vendor::Merchant.all.order('created_at DESC')
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
        format.html { redirect_to admin_vendor_merchants_path, notice: 'Поставщик создан' }
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
        format.html { redirect_to admin_vendor_merchants_path, notice: 'Поставщик обновлен' }
        format.json { render :show, status: :ok, location: @merchant }
      else
        set_custom_merchants
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
      format.html { redirect_to admin_vendor_merchants_url, notice: 'Поставщик удален' }
      format.json { head :no_content }
    end
  end

  # POST /admin/vendor/merchants/1/pricelist
  def pricelist
    fmt = File.extname(params[:vendor_merchant][:pricelist].path).delete(".")
    @merchant.update(format: fmt)
    if ::Vendor::Pricelist.async_import!(@merchant.id, params[:vendor_merchant][:pricelist].path)
      @merchant.update(pricelist_state: 'Прайс в очереди', pricelist_error: false)
      redirect_to admin_vendor_merchants_url, notice: "Прайс добавлен в обработку"
    else
      redirect_to admin_vendor_merchants_url, error: "Произошла ошибка"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_merchant
      @merchant = ::Vendor::Merchant.find(params[:id])
    end

    def set_custom_merchants
      @custom_merchants = ::Vendor::Merchant::CUSTOM
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def merchant_params
      params.require(:vendor_merchant).permit(:name, :description, :email, :discount,
                                              :f_start, :f_model, :f_name,
                                              :f_code, :f_usd, :f_uah, :f_rrc,
                                              :f_eur, :f_not_in_stock, :encoding,
                                              :format, :required, :currency_order,
                                              :currency_rates, :parser_class, :f_uah_1,
                                              :f_uah_2, :f_monitor, :f_ddp, :f_dclink_ddp,
                                              :f_stock_kharkov, :f_stock_kiev, :not_in_stock)
    end
end
