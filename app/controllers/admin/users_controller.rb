class Admin::UsersController < Admin::BaseController
  before_action :check_admin_permissions
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @q = User.ransack
    @users = @q.result.order(created_at: :desc).page(params[:page])
  end

  def search
    params[:q].each_value do |v| v.strip! end if params[:q]
    @q = User.ransack(params[:q])
    @users = @q.result.order(created_at: :desc).page(params[:page])
    render :index
  end

  def edit
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_users_path
    else
      render :new
    end
  end

  def update
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
      if params[:user][:password].blank?
        params.require(:user).permit(:email, :name, :phone, :role)
      else
        params.require(:user).permit(:email, :name, :phone, :password, :password_confirmation, :role)
      end
    end

    def set_user
      @user = User.find(params[:id])
    end

end
