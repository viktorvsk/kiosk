ActiveAdmin.register Catalog::ProductProperty do
  actions :all, except: [:show]
  filter :name
  menu parent: 'Каталог'
  permit_params :name, :catalog_property_id, :catalog_product_id

  index do
    selectable_column
    column :name
    actions
  end

    form do |f|
    inputs 'Детали' do
      input :property
      input :product
      input :name
    end
    actions
  end
end
