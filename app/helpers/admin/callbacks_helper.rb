module Admin::CallbacksHelper
  def user_list
    User.all.map { |user| [user.name, user.id] }
  end

  def callback_links
    {'news': 'Обработанные', 'olds': 'Не обработанные'}
  end
end
