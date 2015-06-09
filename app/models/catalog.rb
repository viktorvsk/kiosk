module Catalog

  class << self

    def show_new_layout?
      conf = Conf['n.new_layout_sessions'].split(',').map(&:strip).map(&:to_i)
      last_session, sessions_count = conf[0]
      sessions_count = conf[1] || 0
      stale_session = Time.at(last_session) < Time.now.beginning_of_day
      under_limit = Conf['txt.new_layout_limit'].to_i > sessions_count
      if stale_session
        last_session = Time.now.to_i
        sessions_count = 0
        save_sessions_count_for_new_layout(last_session, sessions_count)
      end
      if under_limit
        last_session = Time.now.to_i
        sessions_count = sessions_count + 1
        save_sessions_count_for_new_layout(last_session, sessions_count)
        true
      else
        false
      end
    end

    def table_name_prefix
      'catalog_'
    end

    def strip_phone(phone)
      p = phone.to_s.strip
      return if p.blank?
      p.gsub!(/[^\d]/, '')
      unless p =~ /\A38/
        p = "38#{p}"
      end
      p
    end

    private

    def save_sessions_count_for_new_layout(last_session, sessions_count)
      Conf['n.new_layout_sessions'] = [last_session, sessions_count].join(',')
    end

  end

end
