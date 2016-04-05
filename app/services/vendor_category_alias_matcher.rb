class VendorCategoryAliasMatcher
  @queue = :common

  def self.perform
    categories = Catalog::Category.joins(:aliases).includes(:aliases).all.to_a
    products = Catalog::Product.where("(info->'vendor_category') IS NOT NULL")
    products.map do |product|
      category = categories.detect do |c|
        aliases = c.aliases.map{ |a| a.name.mb_chars.downcase.to_s.strip } + [c.name.mb_chars.downcase.to_s.strip]
        product.vendor_category.mb_chars.downcase.strip.to_s.in?(aliases)
      end
      if category
        product.category = category
      end
      product
    end
    Catalog::Product.transaction do
      products.map(&:save)
    end
  end
end
