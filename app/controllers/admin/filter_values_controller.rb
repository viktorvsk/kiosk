class Admin::FilterValuesController < Admin::BaseController
  before_action :check_admin_permissions
  before_action :set_filter_value, only: [:edit, :update, :destroy]

  def index
    @q = Catalog::FilterValue.ransack
    @filter_values = Catalog::FilterValue.all.order('created_at DESC').page(params[:page])
  end

  def search
    params[:q].each_value do |v| v.strip! end if params[:q]
    @q = Catalog::FilterValue.ransack(params[:q])
    @filter_values = @q.result.order('created_at DESC').page(params[:page])
    render :index
  end

  def new
    @filter_value = Catalog::FilterValue.new
  end

  def create
    @filter_value = Catalog::FilterValue.new(filter_value_params)
    if @filter_value.save
      redirect_to admin_filter_values_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @filter_value.update(filter_value_params)
      redirect_to admin_filter_values_path
    else
      render 'edit'
    end
  end

  def destroy
    @filter_value.destroy
    redirect_to admin_filter_values_path
  end

  private

  def filter_value_params
    params.require(:catalog_filter_value).permit(:name, :display_name, :catalog_filter_id)
  end

  def set_filter_value
    @filter_value = Catalog::FilterValue.find(params[:id])
  end
end
