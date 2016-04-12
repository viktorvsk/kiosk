class Admin::CommentsController < Admin::BaseController
  before_action :check_admin_permissions
  before_action :set_comment, only: [:edit, :update, :destroy]

  def index
    @q = Catalog::Comment.includes(:commentable).ransack
    @comments = @q.result.order(created_at: :desc).page(params[:page])
  end

  def search
    params[:q].each_value(&:strip!)
    @q = Catalog::Comment.includes(:commentable).ransack(params[:q])
    @comments = @q.result.order(created_at: :desc).page(params[:page])
    render :index
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_to admin_comments_path
    else
      render 'edit'
    end
  end

  def destroy
    @comment.destroy
    redirect_to admin_comments_path
  end

  private
  def comment_params
    params.require(:catalog_comment).permit(:body, :active)
  end

  def set_comment
    @comment = Catalog::Comment.find(params[:id])
  end
end
