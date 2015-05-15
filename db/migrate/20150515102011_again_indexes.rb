class AgainIndexes < ActiveRecord::Migration
  def up
    execute "CREATE INDEX newest_products_idx ON catalog_products((info->'newest'))"
    execute "CREATE INDEX homepage_products_idx ON catalog_products((info->'homepage'))"
    execute "CREATE INDEX hit_products_idx ON catalog_products((info->'hit'))"
    execute "CREATE INDEX fulltext_search_idx ON catalog_products USING gin(to_tsvector('english', name))"
  end

  def down
    execute "DROP INDEX newest_products_idx"
    execute "DROP INDEX homepage_products_idx"
    execute "DROP INDEX hit_products_idx"
    execute "DROP INDEX fulltext_search_idx"
  end

end
