class Admin::UserActionsController < Admin::BaseController
  before_action :check_admin_permissions

  def index
    @q = UserProductAction.includes(:user, :product).ransack
    @user_actions = @q.result.order('created_at DESC').page(params[:page])
  end

  def search
    params[:q].each_value(&:strip!)
    @q = UserProductAction.includes(:user, :product).ransack(params[:q])
    @user_actions = @q.result.order('created_at DESC').page(params[:page])
    render :index
  end
end
