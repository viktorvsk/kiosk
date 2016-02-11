class Admin::MarkupsController < Admin::BaseController
  before_action :check_admin_permissions
  before_action :set_markup, only: [:edit, :update, :destroy]

  def index
    markups = case params['scope']
              when 'actives'  then ::Markup.active
              when 'pages'    then ::Markup.pages
              when 'articles' then ::Markup.articles
              when 'helps'    then ::Markup.helps
              when 'slides'   then ::Markup.slides
              else ::Markup.all
              end
    @markups = markups.page(params[:page])
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
    params.require(:markup).permit(:name, :slug, :position, :markup_type, :body,
                                   seo_attributes: [:id, :keywords, :description, :title])
  end

  def set_markup
    @markup = ::Markup.find(params[:id])
  end
end
