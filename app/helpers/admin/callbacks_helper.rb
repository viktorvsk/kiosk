module Admin::CallbacksHelper
  def callbacks
    @callback ||= ::Callback.all
  end
  
  def user_list
    User.all.map { |user| [user.name, user.id] }
  end
end
