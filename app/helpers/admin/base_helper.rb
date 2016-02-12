module Admin::BaseHelper
  def counter(name)
    name = name.to_s
    @counters ||= {}
    return unless name.present?
    return @counters[name] if @counters.key?(name)
    return unless block_given?
    relation = yield
    @counters[name.to_s] ||= relation.count if relation.respond_to?(:count)
  end
end
