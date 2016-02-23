module Admin::UserActionsHelper
  def user_actions_links
    { 'binded' => 'Привязал', 'unbind' => 'Отвязал', 'created' => 'Cоздал', 'updated' => 'Отредактировал', 'destroyed' => 'Удалил' }
  end

  def user_actions_date(params, date)
    if params.blank?
      date
    else
      Date.strptime(params.values.join('/'), '%d/%m/%Y')
    end
  end

  def user_actions_type_select
    UserProductAction::ACTION_TYPES.map{ |t| [t, UserProductAction::ACTION_TYPES.index(t)] }
  end

  def default_action_type_select(params)
    params['actions'].to_i unless params['actions'].blank?
  end
end
