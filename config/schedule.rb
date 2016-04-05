every '01 * * * *' do
  runner 'Resque.enqueue(Binder)'
end

every '20 * * * *' do
  runner 'Resque.enqueue(VendorCategoryAliasMatcher)'
end

every '30 * * * *' do
  runner 'Resque.enqueue(SitemapGenerator)'
end

every '40 * * * *' do
  runner 'Resque.enqueue(PricelistImportAuto)'
end

every '50 * * * *' do
  runner 'PricelistExport.new("ym").async_generate!'
  runner 'PricelistExport.new("pn").async_generate!'
end

every 1.day, at: '4am' do
  runner 'Resque.enqueue(BackupDb)'
  runner 'Order.in_cart.destroy_all'
end
