ActiveAdmin.register Catalog::FilterValue do
  actions :all, except: [:show]
  filter :display_name
  filter :name
  menu parent: 'Каталог'
  permit_params :name, :display_name, :catalog_filter_id

  index do
    selectable_column
    column :name
    column :display_name
    actions
  end

  form do |f|
    inputs 'Детали' do
      input :filter
      input :name
      input :display_name
    end
    actions
  end
end
