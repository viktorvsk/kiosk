json.array!(@admin_confs) do |admin_conf|
  json.extract! admin_conf, :id
  json.url admin_conf_url(admin_conf, format: :json)
end
