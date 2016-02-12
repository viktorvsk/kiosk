class Admin::UserActionController < Admin::BaseController
  before_action :check_admin_permissions
  
  def index
    
  end
end
