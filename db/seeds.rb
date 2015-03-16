user          = User.create!( name: 'Vasya', email: 'vasya@example.com', password: 11111111, phone: '+380931234567' )
admin         = User.create!( name: 'Admin', email: 'admin@example.com', password: 11111111, phone: '+380931234568' )
properties    = Catalog::Property.create!([
    { name: 'Цвет' },
    { name: 'Размер экрана' }
  ])
filters       = Catalog::Filter.create!([
    { name: 'Тип памяти' },
    { name: 'Диагональ экрана' }
  ])
filter_values = Catalog::FilterValue.create!([
    { name: 'DDR3', filter: filters.first },
    { name: 'DDR2', filter: filters.first },
    { name: '7"', filter: filters.last },
    { name: '9"', filter: filters.last },
    {  }
  ])
brands        = Catalog::Brand.create!([
    { name: 'Apple' },
    { name: 'Samsung' }
  ])

categories    = Catalog::Category.create!([
    { name: 'Ноутбуки', slug: 'notebooks' },
    { name: 'Телефоны', slug: 'smartphones'}
  ])
c_props       = Catalog::CategoryProperty.create!([
    { category: categories.first, property: properties.first },
    { category: categories.first, property: properties.last }
  ])
c_brands      = Catalog::CategoryBrand.create!([
    { category: categories.first, property: brands.first },
    { category: categories.first, property: brands.last }
  ])
c_filters     = Catalog::CatalogFilter.create!([
    { category: categories.first, property: filters.first },
    { category: categories.first, property: filters.last }
  ])

merchants     = Vendor::Merchant.create!([
    { name: 'DCLink' }
  ])
vendor_prods  = Vendor::Product.create!([
    name: 'Notebook Acer (335AeT)', articul: '1123AQW-77',
    merchant: merchants.first, product: products.first,
    price: 500, in_stock: true, is_rrc: false
  ])

products      = Catalog::Product.create!([
    {
      name: 'Ноутбук Acer 335Ae-T', slug: 'notebook-acer', model: '335AeT',
      category: categories.first, brand: brands.first,
      fixed_price: true, price: '1000'
    }
  ])
p_props       = Catalog::ProductProperty.create!([
    { product: products.first, property: properties.first, name: 'Черный' }
  ])
p_filters     = Catalog::ProductFilterValue.create!([
    { product: products.first, filter: filter_values.first, position: 1 },
    { product: products.first, filter: filter_values.last, position: 2 }
  ])

# orders        = Order.create!()
# line_items    = LineItem.create!()

# seos          = Seo.create!()
# aliases       = Alias.create!()
# markups       = Markup.create!()
# states        = State.create!()
# images        = Image.create!()

# Conf.create!()
