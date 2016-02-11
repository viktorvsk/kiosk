class Admin::CallbacksController < Admin::BaseController
  before_action :check_admin_permissions
  before_action :set_callback, only: [:edit, :update, :destroy]

  def index
    callbacks = case params['scope']
                 when 'olds' then ::Callback.olds
                 when 'news' then ::Callback.news
                 else ::Callback.all
                 end
    @callbacks = callbacks.page(params[:page])
  end

  def edit
  end

  def update
    if @callback.update(callback_params)
      redirect_to admin_callbacks_path
    else
      render 'edit'
    end
  end

  def destroy
    @callback.destroy
    redirect_to admin_callbacks_path
  end
  
  private
  
  def callback_params
    params.require(:callback).permit(:name, :phone, :body, :active,
                                     :user_id)
  end
      
  def set_callback
    @callback = ::Callback.find(params[:id])  
  end
end
