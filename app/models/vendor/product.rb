module Vendor
  class Product < ActiveRecord::Base
    store_accessor :info, :uah, :usd, :eur, :rrc, :in_stock_kharkov,
                   :in_stock_kiev, :model, :brand, :category, :warranty
    validates :name, :articul, :merchant, :price, presence: true
    validates :in_stock, :is_rrc, inclusion: { in: [true, false] }
    belongs_to :product,
               class_name: Catalog::Product, foreign_key: :catalog_product_id
    belongs_to :merchant,
               class_name: Vendor::Merchant, foreign_key: :vendor_merchant_id
    belongs_to :catalog_category, class_name: Catalog::Category
    has_one :state, as: :stateable
    scope :bound,         -> { where('vendor_products.catalog_product_id IS NOT NULL') }
    scope :unbound,       -> { where('vendor_products.catalog_product_id IS NULL') }
    scope :rrc,           -> { where(is_rrc: true) }
    scope :usd_gt_or_eq,  -> (amount) { currency_from(:usd, amount) }
    scope :usd_lt_or_eq,  -> (amount) { currency_to(:usd, amount) }
    scope :brand_cont,    -> (name) { info_like(:brand, name) }
    scope :category_cont, -> (name) { info_like(:category, name) }
    scope :model_cont,    -> (name) { info_like(:model, name) }
    scope :warranty_cont, -> (name) { info_like(:warranty, name) }

    class << self
      def ransackable_scopes(auth_object = nil)
        if auth_object.try(:admin?)
          [:usd_gt_or_eq, :usd_lt_or_eq, :brand_cont, :category_cont,
           :model_cont, :warranty_cont]
        else
          [:usd_gt_or_eq, :usd_lt_or_eq, :brand_cont, :category_cont,
           :model_cont, :warranty_cont]
        end
      end

      def info_like(column, value)
        where("info->>'#{column}' ILIKE ?", "%#{value}%")
      end

      def currency_from(currency, amount)
        where("nullif((info->>'#{currency}'), '')::float >= ?", amount.to_f)
      end

      def currency_to(currency, amount)
        where("nullif((info->>'#{currency}'), '')::float <= ?", amount.to_f)
      end

      def active
        joins('LEFT JOIN states ON states.stateable_id = vendor_products.id')
          .where('states.stateable_id IS NULL')
          .where(in_stock: true)
      end

      def not_active
        joins(:state)
          .where('states.name = ? OR vendor_products.in_stock = ?',
                 'inactive', false)
      end

      def to_csv
        all
          .map(&:to_csv)
          .join("\n")
      end

      def activate
        ids = all.joins(:state).uniq.pluck(:id)
        State
          .where(stateable_id: ids, stateable_type: 'Vendor::Product')
          .delete_all
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
          State.create(to_create)
        end
      end

      def unbind
        all.bound.update_all(catalog_product_id: nil)
      end

      def bind_to(catalog_product)
        all.update_all(catalog_product_id: catalog_product)
        catalog_product.recount
      end

      def select_rrc
        rrc.active.max_by(&:price).try(:price)
      end
    end

    def bind_to(catalog_product)
      update!(product: catalog_product)
      catalog_product.recount
    end

    def deactivate
      state ? true : create_state(name: 'inactive')
    end

    def activate
      state ? state.destroy : true
    end

    def active?
      !state.present?
    end

    def bound?
      product.present?
    end

    def unbind
      update!(product: nil)
    end

    def to_partial_path
      "admin/#{super}"
    end

    def to_csv
      [
        articul, name, price, in_stock, vendor_merchant_id, catalog_product_id,
        -> { Time.now }.call,
        -> { Time.now }.call,
        info.to_json, is_rrc
      ]
    end

  end
end
