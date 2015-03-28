class Vendor::Product < ActiveRecord::Base
  store_accessor :info, :uah, :usd, :eur, :rrc,
                 :in_stock_kharkov, :in_stock_kiev,
                 :model, :brand, :category,
                 :warranty
  validates :name, :articul, :merchant, :price, presence: true
  validates :in_stock, :is_rrc, :inclusion => { :in => [true, false] }
  belongs_to :product, class_name: Catalog::Product, foreign_key: :catalog_product_id
  belongs_to :merchant, class_name: Vendor::Merchant, foreign_key: :vendor_merchant_id
  belongs_to :catalog_category, class_name: Catalog::Category
  has_one :state, as: :stateable
  scope :active,      ->{ joins('LEFT JOIN states ON states.stateable_id = vendor_products.id').where('states.stateable_id IS NULL') }
  scope :not_active,  ->{ joins(:state).where(states: { name: 'inactive' }) }
  scope :bound,       ->{ where('vendor_products.catalog_product_id IS NOT NULL') }
  scope :unbound,     ->{ where('vendor_products.catalog_product_id IS NULL') }
  scope :rrc,         ->{ where(is_rrc: true) }
  class << self
    def to_csv
      all.map(&:to_csv).join("\n");
    end

    def activate
      ids = all.joins(:state).uniq.pluck(:id)
      State.where(stateable_id: ids, stateable_type: 'Vendor::Product').delete_all
    end

    def deactivate
      to_create = all.active.pluck(:id).map do |id|
        {
          stateable_id: id,
          stateable_type: 'Vendor::Product',
          name: 'inactive'
        }
      end
      State.transaction do
        State.create( to_create )
      end
    end

    def unbind
       all.bound.update_all( catalog_product_id: nil )
    end

    def bind_to( catalog_product )
      all.update_all( product: catalog_product )
    end

    def select_rrc
      all.rrc.first
    end
  end

  def bind_to( catalog_product )
    update!( product: catalog_product )
  end

  def activate
    create_state(name: 'inactive')
  end

  def deactivate
    state ? state.destroy : true
  end

  def active?
    !state.present?
  end

  def bound?
    product.present?
  end

  def unbind
    update!( product: nil )
  end

  def to_partial_path
    "admin/#{super}"
  end

  def to_csv
    [
      articul,
      name,
      price,
      in_stock,
      vendor_merchant_id,
      catalog_product_id,
      -> { Time.now }.call,
      -> { Time.now }.call,
      info.to_json,
      is_rrc
    ]
  end
end






a1 = [2,3,4,5]
a2 = [2,3,4,5,6,7,8,9,10]












