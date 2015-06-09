class Admin::ConfsController < Admin::BaseController
  before_action :check_admin_permissions
  before_action :set_conf, only: [:edit, :update]

  # GET /admin/confs
  # GET /admin/confs.json
  def index
    @confs = Conf.order(:created_at).all.reject{ |c| c.var =~ /\An\./ }
  end

  # PATCH/PUT /admin/confs/1
  # PATCH/PUT /admin/confs/1.json
  def update
    @conf.update(conf_params) ? head(200) : head(422)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_conf
      @conf = Conf.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def conf_params
      params[:conf].permit(:value)
    end
end
