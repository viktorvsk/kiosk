class Catalog::Category < ActiveRecord::Base
  store_accessor :info, :tax, :tax_max, :tax_threshold
  validates :name, presence: true
  has_many :products, class_name: Catalog::Product, dependent: :nullify, foreign_key: :catalog_category_id
  has_many :vendor_products, through: :products, class_name: ::Vendor::Product

  def tax_for(value)
    value = value.to_f.ceil
    if value > tax_threshold.to_f.ceil
      tax_max.to_f.ceil
    else
      tax.to_f.ceil
    end
  end

end
