class UsersController < CatalogController
  before_action :set_user

  def show
    if @user.persisted?
      @orders = @user.orders.includes(:line_items)
    else
      @orders = session[:ordered] ? Order.where(id: session[:ordered].to_s.split).includes(:line_items) : Order.none
    end
  end

  def create
    redirect_to :back, notice: 'Работает'
  end

  def update
    if @user.update(user_params)
      redirect_to :back, notice: 'Профиль успешно обновлен'
    else
      @orders = @user.orders.includes(:line_items)
      render :show
    end
  end

  def callback
    phone = Catalog.strip_phone(params[:callback][:phone])
    user = User.where(phone: phone).first
    unless user
      pass = Devise.friendly_token
      h = {
        password: pass,
        password_confirmation: pass,
        phone: phone,
        email: "#{phone}@evotex.kh.ua",
        name: params[:callback][:name]
      }
      user = User.new(h)
      unless user.valid?
        redirect_to root_path, alert: "Телефон указан неверно (#{params[:callback][:phone]}), пожалуйста, укажите настоящий телефон, что бы мы могли связаться с Вами" and return
      end
      user.save
    end
    user.callbacks.create(callback_params)
    redirect_to root_path, notice: 'Спасибо! Вам перезвонят в ближайшее время'
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

    def callback_params
      params[:callback].permit(:name, :phone, :body)
    end
end
