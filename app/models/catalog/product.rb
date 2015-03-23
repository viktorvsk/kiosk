class Catalog::Product < ActiveRecord::Base
  # include Slugable
  store_accessor :info, :video, :description, :accessories
  validates :name, :category, presence: true
  validates :model, :name, uniqueness: true
  belongs_to :category, class_name: Catalog::Category, foreign_key: :catalog_category_id
  belongs_to :brand, class_name: Catalog::Brand, foreign_key: :catalog_brand_id
  has_many :vendor_products, class_name: Vendor::Product, dependent: :nullify, foreign_key: :catalog_product_id

  def recount
  end

  def bind(vendor_product)
    vendor_product.update(product: self)
  end

  def unbind_all
    vendor_products.update_all(product: nil)
  end

  def filters=(values)
  end

  def properties=(values)
  end

  def images=(values)
  end

  def category=(value)
    case value
      when String
        cat = Catalog::Category.where(name: value).first_or_create
        super(cat)
      when Catalog::Category
        super(value)
      else
        raise ArgumentError, 'Expected Category or category name'
      end
  end

  def brand=(value)
  end

end
