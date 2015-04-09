class Binder
  @queue = :binder
  class << self

    def perform
      Binder.new.bind!
    end

  end

  def initialize
    set_catalog_products
    set_vendor_products
  end

  def bind!
    grouped_catalog_products = group(@catalog_products)
    grouped_vendor_products = group(@vendor_products)

    catalog_models = to_model(grouped_catalog_products)
    vendor_models = to_model(grouped_vendor_products)

    @boundable = catalog_models & vendor_models

    @catalog_products = to_boundable(@catalog_products)
    @vendor_products = to_boundable(@vendor_products)

    ::Vendor::Product.transaction do
      @vendor_products.each do |vendor_product|
        bind_vendor_product(vendor_product)
      end
    end
  end

private
  def set_catalog_products
    @catalog_products ||=  ::Catalog::Product
      .select(:id, :model, :name, :price, :fixed_price, :catalog_category_id)
      .all
      .select{ |product| product.model.present? }
      .map{ |product| clear_model(product) }
      .select{ |product| product.model.present? }
  end

  def set_vendor_products
    @vendor_products = ::Vendor::Product
      .unbound
      .select(:id, :info, :name)
      .all
      .select{ |product| product.model.present? }
      .map{ |product| clear_model(product) }
      .select{ |product| product.model.present? }
  end

  def clear_model(product)
    product.model.gsub!(/[^\w]/, '')
    product.model.gsub!(/\s+/, '')
    product.model = product.model.mb_chars.downcase.strip.to_s
    product
  end

  def group(products)
    products
      .map{ |product| [product.id, product.model] }
      .group_by{ |product| product.last }
  end

  def to_model(products)
    products
      .map{ |k,v| v.map{ |product| product.last} }
      .flatten
  end

  def to_boundable(products)
    products
      .select{ |p| p.model.in?(@boundable) }
  end

  def bind_vendor_product(vendor_product)
    ids = @vendor_products
      .select{ |v_p| v_p.model == vendor_product.model }
      .map(&:id)
    product = @catalog_products
      .detect{ |p| p.model == vendor_product.model }
    ::Vendor::Product.where(id: ids).bind_to(product)
    print '+' * ids.size
  end


end
