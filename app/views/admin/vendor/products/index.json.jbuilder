json.array!(@admin_vendor_products) do |admin_vendor_product|
  json.extract! admin_vendor_product, :id
  json.url admin_vendor_product_url(admin_vendor_product, format: :json)
end
