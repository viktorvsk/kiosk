ActiveAdmin.register Catalog::Property do
  actions :all, except: [:show]
  menu parent: 'Каталог'
end
