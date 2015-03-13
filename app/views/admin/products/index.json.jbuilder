json.array!(@catalog_products) do |catalog_product|
  json.extract! catalog_product, :id
  json.url catalog_product_url(catalog_product, format: :json)
end
