class Admin::MarkupsController < Admin::BaseController
  before_action :check_admin_permissions
  before_action :set_markup, only: [:edit, :update, :destroy]

  def new
    @markup = Markup.new
  end

  def create
    @markup = Markup.create(markup_params)
    if @markup.save
      redirect_to admin_markups_path
    else
      render 'new'
    end
  end

  def index
    @q = Markup.ransack
    @markups = Markup.order(created_at: :desc).page(params[:page])
  end

  def search
    params[:q].each_value do |v| v.strip! end if params[:q]
    @q = Markup.ransack(params[:q])
    @markups = @q.result.order('created_at DESC').page(params[:page])
    render :index
  end
  
  def edit
    @markup.build_seo unless @markup.seo
  end

  def update
    if @markup.update(markup_params)
      redirect_to admin_markups_path
    else
      render 'edit'
    end
  end

  def destroy
    @markup.destroy
    redirect_to admin_markups_path
  end

  private
  def markup_params
    params.require(:markup).permit(:name, :slug, :position, :markup_type, :body, :active,
                                   seo_attributes: [:id, :keywords, :description, :title])
  end

  def set_markup
    @markup = Markup.find(params[:id])
  end
end
