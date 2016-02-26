module Admin::FilterValuesHelper
  def filters
    Catalog::Filter.pluck(:name, :id)
  end
end
