module Admin::BaseHelper
  def counter(name)
    @counters ||= {}
    return unless name.present?
    return @counters[name.to_s] unless block_given?
    @counters[name.to_s] ||=  yield
  end
end
