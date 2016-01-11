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
    column 'Товар' do |comment|
      link_to "#{commentable_product(comment).name}", product_path(commentable_product(comment))
    end
    actions
  end

  form do |f|
    f.inputs "Детали" do
      li link_to 'Ссылка на товар', product_path(commentable_product(object))
      f.input :body
      f.input :active
    end
    f.actions
  end

end
