require 'spec_helper'

RSpec.describe ActivePricelist::Base do
  before(:all) do
    @xml_price = ActivePricelist::Base.new do |pl|
      pl.file           = ActivePricelist.root.join 'spec', 'support', 'price.xml'
      pl.rates          = { 'rrc' => 1, 'usd' => 25, 'eur' => 30, 'uah' => 1 }
      pl.currency_order = %w(rrc usd uah eur)
      pl.required       = %w(name)
      pl.not_in_stock   = %w(-)
      pl.start          = '//goods/item'
      pl.columns        = {
        'name'  =>  'gname/text()',
        'usd'   =>  'gprice_usd/text()',
        'rrc'   =>  'rrc/text()',
        'code'  =>  'id/text()'
      }
    end

    @xls_price = ActivePricelist::Base.new do |pl|
      pl.file           = ActivePricelist.root.join 'spec', 'support', 'price.xls'
      pl.rates          = { 'rrc' => 1, 'usd' => 25, 'eur' => 30, 'uah' => 1 }
      pl.currency_order = %w(usd rrc uah eur)
      pl.required       = %w(name)
      pl.start          = 1
      pl.not_in_stock   = %w(-)
      pl.columns  = {
        'name'     => 1,
        'rrc'      => 2,
        'usd'      => 6,
        'in_stock' => 7
      }
    end

    @xml_price.perform
    @xls_price.perform

  end

  it 'parses XML price list to an Array' do
    expect(@xml_price.products.class).to eq Array
  end

  it 'parses XLS price list to an Array' do
    expect(@xls_price.products.class).to eq Array
  end

  it 'parses XML price list to an Array of Hashes' do
    expect(@xml_price.products.first.class).to eq Hash
    expect(@xml_price.products.last.class).to eq Hash
  end

  it 'parses XLS price list to an Array of Hashes' do
    expect(@xls_price.products.first.class).to eq Hash
    expect(@xls_price.products.last.class).to eq Hash
  end

  it 'has correct names for parsed products from XML' do
    expect(@xml_price.products.first['name']).to eq "Защитная пленка DIGI для планшета Lenovo IdeaTab A7600 AF матовая (6172476)"
    expect(@xml_price.products.last['name']).to eq "SSD накопитель 30 Гб Kingston SMS200 (SMS200S3/30G)"
  end

  it 'has correct names for parsed products from XLS' do
    expect(@xls_price.products.first['name']).to eq "Защитная пленка DIGI для планшета Lenovo IdeaTab A7600 AF матовая (6172476)"
    expect(@xls_price.products.last['name']).to eq "SSD накопитель 30 Гб Kingston SMS200 (SMS200S3/30G)"
  end

  it 'choses RRC over others' do
    expect(@xml_price.products.first['price'].to_i).to eq 199
  end

end
