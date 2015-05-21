ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :name, :phone, :role
  actions :all, except: [:show]
  menu priority: 1, parent: "CRM"
  filter :email

  scope 'Администраторы', :admins
  scope 'Контент менеджеры', :contents
  scope 'Клиенты', :customers

  index do
    selectable_column
    column :email
    column :uniq_product_actions_today do |user|
      user.uniq_product_actions_today
    end
    actions
  end

  controller do

    def update
      if params[:user][:password].blank?
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end
      super
    end

  end

  form do |f|
    f.inputs "Детали" do
      f.input :email
      f.input :name
      f.input :phone
      f.input :password
      f.input :password_confirmation
      f.input :role, as: :select, collection: User::ROLES.map{ |r| [t("roles.#{r}"), r] }, include_blank: false
    end
    f.actions
  end

end
