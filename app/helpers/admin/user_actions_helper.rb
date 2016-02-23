module Admin::UserActionsHelper
  def user_actions_links
    { 'binded' => 'Привязал', 'unbind' => 'Отвязал', 'created' => 'Cоздал', 'updated' => 'Отредактировал', 'destroyed' => 'Удалил' }
  end

  def user_actions_date(params, date)
    return Date.strptime(params.values.join('/'), '%d/%m/%Y') unless params.blank?
    date
  end

  def user_action_types
    UserProductAction::ACTION_TYPES.map{ |t| [t, UserProductAction::ACTION_TYPES.index(t)] }
  end

  def default_action_type(params)
    params['actions'].to_i unless params['actions'].blank?
  end
end
