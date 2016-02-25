class Admin::UserActionsController < Admin::BaseController
  before_action :check_admin_permissions
  
  def index
    @filtered_actions = UserActionsService.new(params).call
    @user_actions = @filtered_actions.all.order(created_at: :desc).page(params[:page])
  end
end
