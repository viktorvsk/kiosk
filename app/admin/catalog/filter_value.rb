ActiveAdmin.register Catalog::FilterValue do
  actions :all, except: [:show]
  menu parent: 'Каталог'
end
