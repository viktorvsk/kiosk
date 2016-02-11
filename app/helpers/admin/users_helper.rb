module Admin::UsersHelper
  def users
    @users ||= User.all
  end

  def user_links
    {'admins': 'Администраторы', 'contents': 'Менеджеры', 'customers': 'Клиенты'}
  end

  def user_roles
    User::ROLES.map{ |r| [t("roles.#{r}"), r] }
  end
end
