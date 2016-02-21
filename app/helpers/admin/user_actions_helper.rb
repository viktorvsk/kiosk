module Admin::UserActionsHelper
  def user_actions_links
    { 'binded' => 'Привязал', 'unbind' => 'Отвязал', 'created' => 'Cоздал', 'updated' => 'Отредактировал', 'destroyed' => 'Удалил' }
  end
end
