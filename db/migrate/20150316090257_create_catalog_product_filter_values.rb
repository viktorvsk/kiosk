class CreateCatalogProductFilterValues < ActiveRecord::Migration
  def change
    create_table :catalog_product_filter_values do |t|
      t.belongs_to :catalog_product, null: false, index: true
      t.belongs_to :catalog_filter_value, null: false, index: true

      t.timestamps null: false
    end

    # @TODO Restrcit creation of filter values that not included to
    # products category filters at database level.
    add_index :catalog_product_filter_values, [:catalog_product_id, :catalog_filter_value_id],
                                              unique: true,
                                              name: :product_filter_values_index
  end
end
