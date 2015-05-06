ActiveAdmin.register Callback do
  permit_params :name, :phone, :body, :user_id, :active
  actions :all, except: [:show]
  menu parent: "CRM"
  filter :name
  filter :phone
  filter :user
  scope 'Не обработанные', :news
  scope 'Обработанные', :olds
  index do
    selectable_column
    column :name
    column :phone
    column :user
    actions
  end

  form do |f|
    f.inputs "Детали" do
      f.input :name
      f.input :phone
      f.input :active
      f.input :body
      f.input :user
    end
    f.actions
  end

end
