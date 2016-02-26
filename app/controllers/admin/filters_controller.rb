class Admin::FiltersController < Admin::BaseController
  before_action :check_admin_permissions
  before_action :set_filter, only: [:edit, :update, :destroy]

  def index
    @filters = Catalog::Filter.all.page(params[:page])
  end

  def new
    @filter = Catalog::Filter.new
  end

  def create
    @filter = Catalog::Filter.create(params_filter)
    if @filter.save
      redirect_to admin_filters_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @filter.update(params_filter)
      redirect_to admin_filters_path
    else
      render 'edit'
    end
  end

  def destroy
    @filter.destroy
    redirect_to admin_filters_path
  end
  
  private
  
  def params_filter
    params.require(:catalog_filter).permit(:name, :display_name)
  end

  def set_filter
    @filter = Catalog::Filter.find(params[:id])
  end
end
