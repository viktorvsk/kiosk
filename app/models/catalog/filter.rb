class Catalog::Filter < ActiveRecord::Base
  validates :name, presence: true
  validates :name, uniqueness: {case_sensitive: false}
  has_many :values, class_name: Catalog::FilterValue,
                    foreign_key: :catalog_filter_id,
                    dependent: :delete_all
  has_many :category_filters, class_name: Catalog::CategoryFilter,
                              foreign_key: :catalog_filter_id,
                              dependent: :delete_all
  def value=(val)
    val.strip!
  end

  def add_value(val_name, postfix = nil)
    return unless val_name.present?
    val_name.strip!
    val_name = "#{val_name} (#{postfix})" if postfix.present?
    val_name_search = val_name.mb_chars.downcase
    value = Catalog::FilterValue.where('LOWER(name) = ?', val_name_search).first
    values.create!(name: val_name) unless value
  end
end
