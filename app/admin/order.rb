ActiveAdmin.register Order do
  menu parent: 'CRM'
  actions :all, except: [:show]

  scope 'В корзине', :in_cart
  scope 'К оплате', :checkout
  scope 'Завершенные', :completed
  scope 'Незаваершенные', :unknown


  filter :id, as: :string
  filter :user, as: :select, collection: User.all.map{ |u| ["#{u.name} #{u.phone}".presence || u.email, u.id] }
  filter :created_at
  filter :completed_at
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  permit_params :state
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end

  controller do
    def scoped_collection
      super.includes :line_items, user: :orders
    end
  end

  index do
    selectable_column
    column "Заказ" do |order|
      render 'admin/orders/info', order: order
    end
    column "Клиент" do |order|
      render 'admin/orders/client', user: order.user if order.user
    end
    column "Комментарий" do |order|
      order.comment
    end
    column "Товаров" do |order|
      order.items_count
    end
    column "Итого" do |order|
      "#{order.total_sum} грн."
    end
    column "Плюс" do |order|
      "#{order.total_income} грн."
    end
    actions
  end


end
