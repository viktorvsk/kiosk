json.array!(@admin_markups) do |admin_markup|
  json.extract! admin_markup, :id
  json.url admin_markup_url(admin_markup, format: :json)
end
