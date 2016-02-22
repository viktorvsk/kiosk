class Admin::UserActionsController < Admin::BaseController
  before_action :check_admin_permissions
  
  def index
    user_actions = if params['scope']
                     UserProductAction.send(params['scope']) 
                   else
                     UserProductAction.all
                   end
    @user_actions = user_actions.order(created_at: :desc).page(params[:page])
  end
end
