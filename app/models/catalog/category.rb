class Catalog::Category < ActiveRecord::Base
  store_accessor :info, :tax, :tax_max, :tax_threshold
  validates :name, presence: true
  has_many :products, class_name: Catalog::Product, dependent: :nullify, foreign_key: :catalog_category_id
  has_many :vendor_products, through: :products, class_name: ::Vendor::Product
  has_many :category_properties, class_name: Catalog::CategoryProperty,
                                 foreign_key: :catalog_category_id,
                                 autosave: true,
                                 dependent: :delete_all
  has_many :properties, through: :category_properties

  def tax_for(value)
    value = value.to_f.ceil
    if value > tax_threshold.to_f.ceil
      tax_max.to_f.ceil
    else
      tax.to_f.ceil
    end
  end

  def reorder(props)
    category_properties.each do |property|
      position = props[property.id.to_s].try(:fetch, 'position').to_i
      property.position = position
    end
    self.save!
  end

  def reorder_all
    transaction do
      products
        .joins(:properties)
        .includes(:properties, category: :properties)
        .find_each(&:sync_properties_position)
    end
  end

end
