class Catalog::Product < ActiveRecord::Base
  # include Slugable
  store_accessor :info, :video, :description, :accessories
  validates :name, :category, presence: true
  validates :model, :name, uniqueness: true
  belongs_to :category, class_name: Catalog::Category, foreign_key: :catalog_category_id
  belongs_to :brand, class_name: Catalog::Brand, foreign_key: :catalog_brand_id
  has_many :vendor_products, class_name: Vendor::Product, dependent: :nullify, foreign_key: :catalog_product_id
  scope :bound, -> { joins(:vendor_products) }

  class << self
    def unbound
      joins('LEFT JOIN vendor_products ON vendor_products.catalog_product_id = catalog_products.id')
        .where('vendor_products.catalog_product_id IS NULL')
    end

    def bound_with(number)
      select('catalog_products.*')
        .joins(:vendor_products)
        .group('catalog_products.id')
        .having('count(vendor_products.id) >=  ?', number)
    end

    def recount
      transaction do
        all.eager_load(:vendor_products, :category).find_each do |product|
          product.recount
        end
      end
    end
  end

  def recount
    return if fixed_price?
    rrc = vendor_products.select_rrc
    if rrc
      # @TODO Log if more than one RRC present
      update(price: rrc)
    else
      prices = vendor_products.active.map do |vendor_product|
        vendor_product.price + category.tax_for(vendor_product.price)
      end
      update(price: prices.min)
    end
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
