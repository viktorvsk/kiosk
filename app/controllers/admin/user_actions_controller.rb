class Admin::UserActionsController < Admin::BaseController
  before_action :check_admin_permissions
  
  def index
    user_actions = case params['scope']
                    when 'binded' then UserProductAction.binded
                    when 'unbind' then UserProductAction.unbind
                    when 'created' then UserProductAction.created
                    when 'updated' then UserProductAction.updated
                    when 'destroyed' then UserProductAction.destroyed
                    else UserProductAction.all
                    end
    @user_actions = user_actions.page(params[:page])
  end
end
