class Admin::ConfsController < Admin::BaseController
  before_action :set_admin_conf, only: [:show, :edit, :update, :destroy]

  # GET /admin/confs
  # GET /admin/confs.json
  def index
    @admin_confs = Admin::Conf.all
  end

  # GET /admin/confs/1
  # GET /admin/confs/1.json
  def show
  end

  # GET /admin/confs/new
  def new
    @admin_conf = Admin::Conf.new
  end

  # GET /admin/confs/1/edit
  def edit
  end

  # POST /admin/confs
  # POST /admin/confs.json
  def create
    @admin_conf = Admin::Conf.new(admin_conf_params)

    respond_to do |format|
      if @admin_conf.save
        format.html { redirect_to @admin_conf, notice: 'Conf was successfully created.' }
        format.json { render :show, status: :created, location: @admin_conf }
      else
        format.html { render :new }
        format.json { render json: @admin_conf.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/confs/1
  # PATCH/PUT /admin/confs/1.json
  def update
    respond_to do |format|
      if @admin_conf.update(admin_conf_params)
        format.html { redirect_to @admin_conf, notice: 'Conf was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_conf }
      else
        format.html { render :edit }
        format.json { render json: @admin_conf.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/confs/1
  # DELETE /admin/confs/1.json
  def destroy
    @admin_conf.destroy
    respond_to do |format|
      format.html { redirect_to admin_confs_url, notice: 'Conf was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_conf
      @admin_conf = Admin::Conf.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_conf_params
      params[:admin_conf]
    end
end
