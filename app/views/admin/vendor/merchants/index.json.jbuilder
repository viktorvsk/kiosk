json.array!(@admin_vendor_merchants) do |admin_vendor_merchant|
  json.extract! admin_vendor_merchant, :id
  json.url admin_vendor_merchant_url(admin_vendor_merchant, format: :json)
end
