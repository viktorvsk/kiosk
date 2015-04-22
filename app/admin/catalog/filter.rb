ActiveAdmin.register Catalog::Filter do
  actions :all, except: [:show]
  filter :display_name
  filter :name
  menu parent: 'Каталог'
  permit_params :name, :display_name

  index do
    selectable_column
    column :name
    column :display_name
    actions
  end
end
