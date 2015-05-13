class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :active_admin_comments, ["resource_id", "resource_type"]
    add_index :active_admin_comments, ["author_id", "author_type"]
    add_index :comments, ["commentable_id", "commentable_type"]
    add_index :ckeditor_assets, ["assetable_id", "assetable_type"]
    add_index :images, ["imageable_id", "imageable_type"]
    add_index :seos, ["seoable_id", "seoable_type"]
    add_index :vendor_products, ['catalog_product_id', :vendor_merchant_id], name: "vendor_products_product_merchant"
  end
end
