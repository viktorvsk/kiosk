ActiveAdmin.register Catalog::Filter do
  actions :all, except: [:show]
  menu parent: 'Каталог'
end
