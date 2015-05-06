ActiveAdmin.register Catalog::Comment do
  permit_params :body, :active
  actions :all, except: [:show]
  menu parent: "CRM"
  filter :created_at
  scope 'Не обработанные', :news
  scope 'Обработанные', :olds
  index do
    selectable_column
    column :created_at
    actions
  end

  form do |f|
    f.inputs "Детали" do
      f.input :body
      f.input :active
    end
    f.actions
  end

end
