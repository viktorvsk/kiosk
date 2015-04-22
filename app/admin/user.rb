ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation
  actions :all, except: [:show]
  menu priority: 1, parent: "CRM"
  filter :email
  index do
    selectable_column
    column :email
    actions
  end

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end
