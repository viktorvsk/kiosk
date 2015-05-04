ActiveAdmin.register Order do
  menu parent: 'CRM'
  actions :all, except: [:show]
  filter :code
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end

  index do
    selectable_column
    column "Заказ" do |order|
      order.id
    end
    column "Клиент" do |order|
      order.name
    end
    column "Комментарий" do |order|
      order.comment
    end
    column "Товары" do |order|
      order.name
    end
    column "Итого" do |order|
      order.total_sum
    end
    actions
  end


end
