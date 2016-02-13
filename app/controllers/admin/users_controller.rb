class Admin::UsersController < Admin::BaseController
  before_action :check_admin_permissions
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    users = case params['scope']
            when 'admins'      then User.admins
            when 'contents'    then User.contents
            when 'customers'   then User.customers
            else User.all
            end
    @users = users.page(params[:page])
  end

  def edit
  end
  
  def update
    clean_password
    if @user.update(user_params)
      redirect_to admin_users_path
    else
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path
  end

  private
  def user_params
    params.require(:user).permit(:email, :name, :phone, :password, :password_confirmation, :role)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def clean_password
    params[:user].slice!('password', 'password_confirmation') if params[:user][:password].blank?
  end
end
