class UserActionsService
  attr_accessor :params
  
  def initialize(params)
    @params = params
  end

  def call
    user_actions = UserProductAction
    if params['start'] && params['end']
      user_actions = filter_by_date(user_actions)
    end
    user_actions = filter_by_action_type(user_actions) unless params['actions'].blank?
    user_actions
  end

  private
  
  def filter_by_date(user_actions)
    start_day, end_day = build_date(params['start'], params['end'])
    user_actions.where(created_at: start_day.beginning_of_day..end_day.end_of_day) 
  end

  def filter_by_action_type(user_actions)
    user_actions.where(action_type: action_type)
  end

  def action_type
    UserProductAction::ACTION_TYPES[params['actions'].to_i]
  end
  
  def build_date(start_date, end_date)
    [start_date, end_date].map{ |day| DateTime.strptime(day.values.join('/'), '%d/%m/%Y') }
  end
end
