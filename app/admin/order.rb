ActiveAdmin.register Order do
  menu parent: 'CRM'
  actions :all, except: [:show, :destroy]

  (1..12).each do |month|
    scope I18n.l(Date.new(Date.today.year, month, 1), format: "%b"), "month_#{month}"
  end

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
  permit_params :state, :comment, :address, :user_id
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
    column "Информация" do |order|
      render 'admin/orders/info', order: order
    end
    column "Клиент" do |order|
      render 'admin/orders/client', order: order
    end
    column "Комментарии и товары" do |order|
      order.info['comment'].try(:html_safe)
    end
    column "" do |order|
      render 'admin/orders/actions', order: order
    end
  end

  form do |f|
    render 'admin/orders/form', f: f

  end


end
