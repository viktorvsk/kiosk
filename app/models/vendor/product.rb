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
    scope :bound,         ->          { where('vendor_products.catalog_product_id IS NOT NULL') }
    scope :unbound,       ->          { where('vendor_products.catalog_product_id IS NULL') }
    scope :rrc,           ->          { where(is_rrc: true) }
    scope :usd_gt_or_eq,  -> (amount) { currency_from(:usd, amount) }
    scope :usd_lt_or_eq,  -> (amount) { currency_to(:usd, amount) }
    scope :brand_cont,    -> (name)   { info_like(:brand, name) }
    scope :category_cont, -> (name)   { info_like(:category, name) }
    scope :model_cont,    -> (name)   { info_like(:model, name) }
    scope :warranty_cont, -> (name)   { info_like(:warranty, name) }
    scope :active,        ->          { where(in_stock: true, current_price: true, trashed: false) }
    scope :not_active,    ->          { where('in_stock = false OR current_price = false OR trashed = true') }

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

      def to_csv
        all.map(&:to_csv).join("\n")
      end

      def activate
        all.update_all(current_price: true)
      end

      def deactivate
        all.update_all(current_price: false)
      end

      def unbind
        all.bound.update_all(catalog_product_id: nil)
      end

      def bind_to(catalog_product)
        all.update_all(catalog_product_id: catalog_product)
        catalog_product.recount
      end

      def select_rrc
        rrc.active.max_by(&:price).try(:price).to_f.ceil
      end
    end

    def search_marketplace(marketplace, searcher)
      marketplace.new(send(searcher)).search
    end

    def bind_to(catalog_product)
      update!(product: catalog_product)
      catalog_product.recount
    end

    def active?
      current_price? && in_stock? && !trashed?
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
