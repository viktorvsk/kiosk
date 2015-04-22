ActiveAdmin.register Catalog::Property do
  actions :all, except: [:show]
  filter :name
  menu parent: 'Каталог'
  permit_params :name

  index do
    selectable_column
    column :name
    actions
  end
end
