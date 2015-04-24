module Catalog
  class CategoryProductsUpdater
    @queue = :category_products_updater
    def self.async_update(category_id)
      Resque.enqueue(Catalog::CategoryProductsUpdater, category_id)
    end
    def self.perform(category_id)
      Catalog::Category.find(category_id).products.recount
    end
  end
end
