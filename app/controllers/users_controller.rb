class UsersController < CatalogController
  before_action :set_user

  def show
  end

  def create
    redirect_to :back, notice: 'Работает'
  end

  def update
    if @user.update!(user_params)
      redirect_to :back, notice: 'Профиль успешно обновлен'
    else
      redirect_to :back, error: 'При обновлении профиля произошла ошибка'
    end
  end

  private
  def set_user
    @user = current_user || User.new
  end

  def user_params
    if params[:user][:password].blank? || params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    params[:user].permit(:name, :phone, :email, :password, :password_confirmation)
  end
end
