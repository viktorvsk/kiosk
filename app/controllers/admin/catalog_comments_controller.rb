class Admin::CatalogCommentsController < Admin::BaseController
  before_action :check_admin_permissions
  before_action :set_comment, only: [:edit, :update, :destroy]

  def index
    comments = case params['scope']
                when 'non-processing' then Catalog::Comment.with_product.news
                when 'processing' then Catalog::Comment.with_product.olds
                else Catalog::Comment.with_product
                end
    @comments = comments.page(params[:page])
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_to admin_catalog_comments_path
    else
      render 'edit'
    end
  end
  
  def destroy
    @comment.destroy
    redirect_to admin_catalog_comments_path
  end
  
  private
  def comment_params
    params.require(:catalog_comment).permit(:body, :active)
  end
  
  def set_comment
    @comment = Catalog::Comment.find(params[:id])
  end
end
