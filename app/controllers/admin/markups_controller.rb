class Admin::MarkupsController < Admin::BaseController
  before_action :set_admin_markup, only: [:show, :edit, :update, :destroy]

  # GET /admin/markups
  # GET /admin/markups.json
  def index
    @admin_markups = Admin::Markup.all
  end

  # GET /admin/markups/1
  # GET /admin/markups/1.json
  def show
  end

  # GET /admin/markups/new
  def new
    @admin_markup = Admin::Markup.new
  end

  # GET /admin/markups/1/edit
  def edit
  end

  # POST /admin/markups
  # POST /admin/markups.json
  def create
    @admin_markup = Admin::Markup.new(admin_markup_params)

    respond_to do |format|
      if @admin_markup.save
        format.html { redirect_to @admin_markup, notice: 'Markup was successfully created.' }
        format.json { render :show, status: :created, location: @admin_markup }
      else
        format.html { render :new }
        format.json { render json: @admin_markup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/markups/1
  # PATCH/PUT /admin/markups/1.json
  def update
    respond_to do |format|
      if @admin_markup.update(admin_markup_params)
        format.html { redirect_to @admin_markup, notice: 'Markup was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin_markup }
      else
        format.html { render :edit }
        format.json { render json: @admin_markup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/markups/1
  # DELETE /admin/markups/1.json
  def destroy
    @admin_markup.destroy
    respond_to do |format|
      format.html { redirect_to admin_markups_url, notice: 'Markup was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_markup
      @admin_markup = Admin::Markup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_markup_params
      params[:admin_markup]
    end
end
