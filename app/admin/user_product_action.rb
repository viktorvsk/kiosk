ActiveAdmin.register UserProductAction do
  actions :all, except: [:show, :new, :edit]
  menu priority: 1, parent: "CRM"
  filter :created_at
  filter :user, as: :select, collection: User.where(role: %w{admin content})

  scope 'Привязал', :binded
  scope 'Отвязал', :unbind
  scope 'Создал', :created
  scope 'Отредактировал', :updated
  scope 'Удалил', :destroyed

  controller do
    def scoped_collection
      super.includes :user, :product
    end
  end

  index do
    selectable_column
    column :user
    column :action_type
    column :product do |user_action|
      link_to user_action.product.name, edit_admin_product_path(user_action.product) rescue "Товар удален. Код: #{user_action.product_id}"
    end
    column :action do |user_action|
      user_action.action.html_safe
    end
    column :created_at
    # actions
  end

end
