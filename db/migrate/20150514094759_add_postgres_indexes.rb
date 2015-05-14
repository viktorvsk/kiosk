class AddPostgresIndexes < ActiveRecord::Migration
  def up
    execute "CREATE INDEX ON catalog_products((info->'newest'))"
    execute "CREATE INDEX ON catalog_products((info->'homepage'))"
    execute "CREATE INDEX ON catalog_products((info->'hit'))"
  end

  def down
  end
end
